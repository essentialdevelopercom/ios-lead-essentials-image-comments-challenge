//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Cronay on 17.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteImageCommentsLoader: ImageCommentsLoader {
	private let client: HTTPClient
	private let url: URL

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}

	private class Task: ImageCommentsLoaderTask {
		private var completion: ((Result) -> Void)?

		var wrapped: HTTPClientTask?

		init(_ completion: @escaping (Result) -> Void) {
			self.completion = completion
		}

		func complete(with result: Result) {
			completion?(result)
		}

		public func cancel() {
			preventFurtherCompletions()
			wrapped?.cancel()
		}

		private func preventFurtherCompletions() {
			completion = nil
		}
	}

	public typealias Result = ImageCommentsLoader.Result

	@discardableResult
	public func load(completion: @escaping (Result) -> Void) -> ImageCommentsLoaderTask {
		let task = Task(completion)
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }

			task.complete(with: result
							.mapError { _ in Error.connectivity }
							.flatMap { data, response in
								Result {
									try RemoteImageCommentMapper.map(data, from: response).mapToModels()
								}
							})
		}

		return task
	}
}

private extension Array where Element == RemoteImageCommentItem {
	func mapToModels() -> [ImageComment] {
		return map {
			.init(
				id: $0.id,
				message: $0.message,
				createdAt: $0.created_at,
				author: ImageCommentAuthor(username: $0.author.username)
			)
		}
	}
}

//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Cronay on 17.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentsLoader {
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

	public class Task {
		private let wrappedTask: HTTPClientTask

		init(wrappedTask: HTTPClientTask) {
			self.wrappedTask = wrappedTask
		}

		public func cancel() {
			wrappedTask.cancel()
		}
	}

	public typealias Result = Swift.Result<[ImageComment], Swift.Error>

	@discardableResult
	public func load(completion: @escaping (Result) -> Void) -> Task {
		let task = client.get(from: url) { [weak self] result in
			guard self != nil else { return }

			switch result {
			case .failure:
				completion(.failure(Error.connectivity))

			case let .success((data, response)):
				completion(RemoteImageCommentsLoader.map(data, from: response))
			}
		}

		return Task(wrappedTask: task)
	}

	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		Result {
			try RemoteImageCommentMapper.map(data, from: response).mapToModels()
		}
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

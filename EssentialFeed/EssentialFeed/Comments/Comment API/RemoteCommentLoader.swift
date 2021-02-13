//
//  RemoteCommentLoader.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/21/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation


public class RemoteCommentLoader: CommentLoader {
	
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(client: HTTPClient, url: URL) {
		self.url = url
		self.client = client
	}
	public typealias Result = CommentLoader.Result
	
	private class Task: CommentsLoaderTask {
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
	
	@discardableResult
	public func load(completion: @escaping (Result) -> Void) -> CommentsLoaderTask {
		let task = Task(completion)
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }

			task.complete(with: result
							.mapError { _ in Error.connectivity }
							.flatMap { data, response in
								Result {
									try CommentItemMapper.map(data, from: response).toModels()
								}
							})
		}

		return task
	}

	
//	public func load(completion: @escaping (CommentLoader.Result) -> Void) {
//		client.get(from: url) { [weak self] result in
//			guard self != nil else { return }
//			switch result {
//			case .failure:
//				completion(.failure(Error.connectivity))
//			case let .success((data, response)):
//				completion(RemoteCommentLoader.map(data, from: response))
//			}
//		}
//	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> CommentLoader.Result {
		do {
			let items = try CommentItemMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(error)
		}
	}
}

private extension Array where Element == RemoteCommentItem {
	func toModels() -> [Comment] {
		return map { Comment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: $0.author) }
	}
}

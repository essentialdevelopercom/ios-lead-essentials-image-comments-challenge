//
//  RemoteFeedImageCommentLoader.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteFeedImageCommentLoader: FeedImageCommentLoader {
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = FeedImageCommentLoader.Result

	private let url: URL
	private let client: HTTPClient
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	private final class HTTPClientTaskWrapper: FeedImageCommentLoaderTask {
		private var completion: ((Result) -> Void)?
		
		var wrapped: HTTPClientTask?
		
		init(_ completion: @escaping (FeedImageCommentLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: FeedImageCommentLoader.Result) {
			completion?(result)
		}
		
		func cancel() {
			preventFurtherCompletions()
			wrapped?.cancel()
		}
		
		private func preventFurtherCompletions() {
			completion = nil
		}
	}
	
	public func load(completion: @escaping (Result) -> Void) -> FeedImageCommentLoaderTask {
		let task = HTTPClientTaskWrapper(completion)
		task.wrapped = client.get(
			from: url
		) { [weak self] result in
			guard self != nil else { return }
			
			task.complete(
				with: result
					.mapError { _ in Error.connectivity }
					.flatMap { data, response in
						Result {
							try RemoteImageCommentMapper.map(data, from: response).toModels()
						}
					})
		}
		
		return task
	}
	
}

fileprivate struct RemoteImageCommentMapper {
	
	struct RemoteFeedComment: Decodable {
		let id: UUID
		let message: String
		let created_at: Date
		let author: RemoteFeedCommentAuthor
	}
	
	struct RemoteFeedCommentAuthor: Decodable {
		let username: String
	}
	
	private struct Root: Decodable {
		let items: [RemoteFeedComment]
	}
	
	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		guard response.is200x, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteFeedImageCommentLoader.Error.invalidData
		}
		return root.items
	}
	
}

private extension Array where Element == RemoteImageCommentMapper.RemoteFeedComment {
	func toModels() -> [FeedComment] {
		self.map {
			let author = FeedCommentAuthor(username: $0.author.username)
			return FeedComment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: author)
		}
	}
}

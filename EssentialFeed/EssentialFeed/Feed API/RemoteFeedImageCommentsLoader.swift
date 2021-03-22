//
//  RemoteFeedImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Ivan Ornes on 9/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedImageCommentsLoader: FeedImageCommentsLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = FeedImageCommentsLoader.Result
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	private final class HTTPClientTaskWrapper: FeedImageCommentsLoaderTask {
		private var completion: ((FeedImageCommentsLoader.Result) -> Void)?
		
		var wrapped: HTTPClientTask?
		
		init(_ completion: @escaping (FeedImageCommentsLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: FeedImageCommentsLoader.Result) {
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
	
	public func loadImageComments(completion: @escaping (FeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
		let task = HTTPClientTaskWrapper(completion)
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			
			task.complete(with: result
				.mapError { _ in Error.connectivity }
				.flatMap { (data, response) in
					let isValidResponse = response.isOK && !data.isEmpty
					return isValidResponse ? RemoteFeedImageCommentsLoader.map(data, from: response) : .failure(Error.invalidData)
				})
		}
		return task
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try FeedImageCommentsMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(error)
		}
	}
}

private extension Array where Element == RemoteFeedImageCommentItem {
	func toModels() -> [FeedImageComment] {
		return map { FeedImageComment(id: $0.id, message: $0.message, createdAt: $0.ISO8601Date, author: .init(username: $0.author.username)) }
	}
}

private extension RemoteFeedImageCommentItem {
	var ISO8601Date: Date {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = .withInternetDateTime
		return formatter.date(from: createdAt)!
	}
}

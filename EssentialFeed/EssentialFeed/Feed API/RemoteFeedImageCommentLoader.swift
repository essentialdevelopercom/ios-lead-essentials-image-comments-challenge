//
//  RemoteFeedImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 05/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteFeedImageCommentLoader: FeedImageCommentLoader {
	private let url: URL
	private let client: HTTPClient
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = FeedImageCommentLoader.Result
	
	private final class HTTPClientTaskWrapper: FeedImageCommentLoaderTask {
		private var completion: ((Result) -> Void)?
		
		var wrapped: HTTPClientTask?
		
		init(_ completion: @escaping (Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: Result) {
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
	
	public func loadImageCommentData(completion: @escaping (Result) -> Void) -> FeedImageCommentLoaderTask {
		let task = HTTPClientTaskWrapper(completion)
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
						
			switch result {
			case let .success((data, response)):
				task.complete(with: RemoteFeedImageCommentLoader.map(data, from: response))
				
			case .failure:
				task.complete(with: .failure(Error.connectivity))
			}
		}
		return task
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try FeedImageCommentMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(error)
		}
	}
}

private extension Array where Element == RemoteFeedImageComment {
	func toModels() -> [FeedImageComment] {
		return map { FeedImageComment(id: $0.id, message: $0.message, creationDate: $0.created_at, authorUsername: $0.author.username)}
	}
}

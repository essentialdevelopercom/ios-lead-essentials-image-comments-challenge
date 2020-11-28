//
//  RemoteFeedCommentsLoader.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedCommentsLoader {
	
	public typealias Result = Swift.Result<[ImageComment], Error>
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(client: HTTPClient) {
		self.client = client
	}
	
	@discardableResult
	public func load(url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask {
		let task = HTTPClientTaskWrapper(completion: completion)
		
		task.wrappedTask = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			
			switch result {
			case let .success((data, response)):
				task.complete(with: RemoteFeedCommentsLoader.map(data, from: response))
			case .failure(_):
				task.complete(with: .failure(.connectivity))
			}
		}
		
		return task
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try FeedImageCommentsMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(.invalidData)
		}
	}
	
	private final class HTTPClientTaskWrapper: HTTPClientTask {
		private var completion: ((Result) -> Void)?
		var wrappedTask: HTTPClientTask?
		
		init(completion: @escaping (Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: Result) {
			completion?(result)
		}
		
		func cancel() {
			wrappedTask?.cancel()
			preventFurtherCompletions()
		}
		
		private func preventFurtherCompletions() {
			completion = nil
		}
	}
}

private extension Array where Element == CodableFeedImageComment {
	 func toModels() -> [ImageComment] {
		 map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: $0.author.username) }
	 }
 }


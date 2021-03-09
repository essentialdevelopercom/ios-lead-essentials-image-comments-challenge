//
//  RemoteCommentLoader.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteCommentLoader: CommentLoader {
	
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error, Equatable {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	private final class HTTPClientTaskWrapper: CommentLoaderDataTask {
		private var completion: ((CommentLoader.Result) -> Void)?
		
		var wrapped: HTTPClientTask?
		
		init(_ completion: @escaping (CommentLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: CommentLoader.Result) {
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
	
	public func load(completion: @escaping (CommentLoader.Result) -> Void) -> CommentLoaderDataTask {
		let task = HTTPClientTaskWrapper(completion)
		task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
			switch result {
			case let .success((data, response)):
				completion(RemoteCommentLoader.map(data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
		return task
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> CommentLoader.Result {
		do {
			let items = try RemoteCommentMapper.map(data, from: response)
			return .success(items.toLocal())
		} catch {
			return .failure(error)
		}
	}
	
}

private extension Array where Element == RemoteComment {
	func toLocal() -> [Comment] {
		return map { $0.local }
	}
}

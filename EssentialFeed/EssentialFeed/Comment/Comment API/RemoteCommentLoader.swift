//
//  RemoteCommentLoader.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteCommentLoader: CommentLoader {
	
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
	
	private final class CommentTaskWrapper: CommentLoaderTask {
		var wrapped: HTTPClientTask?
		
		func cancel() {
			wrapped?.cancel()
		}
	}
	
	public func load(completion: @escaping (CommentLoader.Result) -> Void) -> CommentLoaderTask {
		let task = CommentTaskWrapper()
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				completion(RemoteCommentLoader.map(data, response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
		
		return task
	}
	
	private static func map(_ data: Data, _ response: HTTPURLResponse) -> CommentLoader.Result {
		guard let comments = try? CommentItemMapper.map(data, response) else {
			return .failure(Error.invalidData)
		}
		
		return .success(comments.toModels())
	}
}

private extension Array where Element == RemoteComment {
	func toModels() -> [Comment] {
		return self.map {
			Comment(id: $0.id, message: $0.message, createAt: $0.createAt, author: $0.author.toModel())
		}
	}
}

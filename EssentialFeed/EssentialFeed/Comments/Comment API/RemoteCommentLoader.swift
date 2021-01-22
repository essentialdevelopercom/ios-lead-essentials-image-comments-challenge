//
//  RemoteCommentLoader.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/21/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation


public class RemoteCommentLoader {
	
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
	
	public func load(completion: @escaping (CommentLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
			case let .success((data, response)):
				completion(RemoteCommentLoader.map(data, from: response))
			}
		}
	}
	
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

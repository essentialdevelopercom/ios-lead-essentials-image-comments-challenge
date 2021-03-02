//
//  RemoteCommentLoader.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteCommentLoader {
	
	private let url: URL
	private let client: HTTPClient
	
	public typealias Result = Swift.Result<[Comment], Error>
	public enum Error: Swift.Error, Equatable {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				completion(RemoteCommentLoader.map(data, from: response))
			case .failure:
				completion(.failure(.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data)  {
			return .success(root.items.toLocal())
		} else {
			return .failure(.invalidData)
		}
	}
	
}

private struct Root: Decodable {
	let items: [RemoteComment]
}

private struct RemoteComment: Decodable {
	public let id: UUID
	public let message: String
	public let createdAt: String
	public let author: RemoteCommentAuthor
	
	enum CodingKeys: String, CodingKey {
		case id
		case message
		case createdAt = "created_at"
		case author
	}
	
	var local: Comment {
		return Comment(id: id, message: message, createdAt: createdAt, author: author.local)
	}
}

private struct RemoteCommentAuthor: Decodable {
	public let username: String
	
	var local: CommentAuthor {
		return CommentAuthor(username: username)
	}
}

private extension Array where Element == RemoteComment {
	func toLocal() -> [Comment] {
		return map { $0.local }
	}
}

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
	
	public func load(completion: @escaping (CommentLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200 && !data.isEmpty else {
					return completion(.failure(Error.invalidData))
				}
				
				guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
					return completion(.failure(Error.invalidData))
				}
				completion(.success(root.items.toModels()))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

public struct Root: Decodable {
	public let items: [RemoteComment]
}

public struct RemoteComment: Decodable {
	let id: UUID
	let message: String
	let createAt: Date
	let author: RemoteCommentAuthor
}

public struct RemoteCommentAuthor: Decodable {
	let username: String
	
	func toModel() -> CommentAuthor {
		return CommentAuthor(username: username)
	}
}

private extension Array where Element == RemoteComment {
	func toModels() -> [Comment] {
		return self.map {
			Comment(id: $0.id, message: $0.message, createAt: $0.createAt, author: $0.author.toModel())
		}
	}
}

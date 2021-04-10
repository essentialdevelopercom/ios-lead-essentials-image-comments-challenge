//
//  RemoteCommentsLoader.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteCommentsLoader: CommentsLoader {
	
	private let client: HTTPClient
	private let url: URL
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = CommentsLoader.Result
	
	public init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}
	
	public func load(completion: @escaping (Result) -> Void) -> CancelableTask {
		let task = HTTPClientTaskWrapper(completion)
		task.wrapped = client.get(from: url, completion: { [weak self] result in
			guard self != nil else { return }
			
			switch result {
			case let .success((data, response)):
				completion(RemoteCommentsLoader.map(data, response))
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		})
		return task
	}
	
	private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
		do {
			let items = try CommentsMapper.map(data, response)
			return .success(items.toModels())
		} catch {
			return .failure(error)
		}
	}
}

private extension Array where Element == RemoteComment {
	func toModels() -> [Comment] {
		return map { Comment(id: $0.id, message: $0.message, createdAt: $0.createdAt, author: $0.author.username) }
	}
}

private class CommentsMapper {
	private struct Root: Decodable {
		var items: [RemoteComment]
	}
	
	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		guard
			isOK(response),
			let root = try? decoder.decode(Root.self, from: data)
		else {
			throw RemoteCommentsLoader.Error.invalidData
		}
		
		return root.items
	}
	
	private static func isOK(_ response: HTTPURLResponse) -> Bool {
		(200...299).contains(response.statusCode)
	}
}

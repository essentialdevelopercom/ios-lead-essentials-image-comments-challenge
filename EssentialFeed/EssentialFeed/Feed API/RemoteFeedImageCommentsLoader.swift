//
//  RemoteFeedImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedImageCommentsLoader {
	private let client: HTTPClient
	private let url: URL
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = FeedImageCommentsLoader.Result
	
	public init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: url, completion: { [weak self] result in
			guard self != nil else { return }
			
			switch result {
			case let .success((data, response)):
				completion(RemoteFeedImageCommentsLoader.map(data, response))
			case .failure(_):
				completion(.failure(Error.connectivity))
			}
		})
	}
	
	private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
		do {
			let items = try FeedImageCommentsMapper.map(data, response)
			return .success(items.toModels())
		} catch {
			return .failure(error)
		}
	}
}

private extension Array where Element == RemoteFeedImageComment {
	func toModels() -> [FeedImageComment] {
		return map { FeedImageComment(id: $0.id, message: $0.message, createdAt: $0.createdAt, author: FeedImageComment.Author(username: $0.author.username)) }
	}
}

private class FeedImageCommentsMapper {
	private struct Root: Decodable {
		var items: [RemoteFeedImageComment]
	}
	
	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedImageComment] {
		guard
			response.isOK,
			let root = try? JSONDecoder().decode(Root.self, from: data)
		else {
			throw RemoteFeedImageCommentsLoader.Error.invalidData
		}
		
		return root.items
	}
}

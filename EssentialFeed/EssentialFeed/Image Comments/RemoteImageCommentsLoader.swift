//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Rakesh Ramamurthy on 01/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentsLoader {
	let client: HTTPClient

	public typealias Result = Swift.Result<[ImageComment], Swift.Error>

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(client: HTTPClient) {
		self.client = client
	}

	public func load(from url: URL, completion: @escaping (Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				completion(RemoteImageCommentsLoader.map(data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try ImageCommentsItemsMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(error)
		}
	}
}

private extension Array where Element == RemoteImageCommentItem {
	func toModels() -> [ImageComment] {
		map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: $0.author.username) }
	}
}

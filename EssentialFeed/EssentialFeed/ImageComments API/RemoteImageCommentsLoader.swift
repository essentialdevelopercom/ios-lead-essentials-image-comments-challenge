//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 27.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteImageCommentsLoader: ImageCommentsLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public typealias Result = ImageCommentsLoader.Result

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }

			switch result {
			case let .success((data, response)):
				completion(Self.map(data, from: response))

			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try ImageCommentItemsMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(error)
		}
	}
}


private extension Array where Element == RemoteImageComment {
	func toModels() -> [ImageComment] {
		return map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.createdAt, author: $0.author.toModel()) }
	}
}

private extension RemoteImageCommentAuthor {
	func toModel() -> ImageCommentAuthor {
		return ImageCommentAuthor(username: username)
	}
}

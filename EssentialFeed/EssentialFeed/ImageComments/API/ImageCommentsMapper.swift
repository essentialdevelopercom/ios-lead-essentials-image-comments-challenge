//
//  ImageCommentItemsMapper.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 27.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsMapper {
	private struct Root: Decodable {
		private let items: [RemoteImageComment]

		struct RemoteImageCommentAuthor: Decodable {
			let username: String
		}

		private struct RemoteImageComment: Decodable {
			let id: UUID
			let message: String
			let createdAt: Date
			let author: RemoteImageCommentAuthor
		}

		var comments: [ImageComment] {
			items.map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.createdAt, author: ImageCommentAuthor(username: $0.author.username)) }
		}
	}

	public enum Error: Swift.Error {
		case invalidData
	}

	private static var decoder: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}

	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
		guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
			throw Error.invalidData
		}

		return root.comments
	}

	private static func isOK(_ response: HTTPURLResponse) -> Bool {
		(200 ... 299).contains(response.statusCode)
	}
}

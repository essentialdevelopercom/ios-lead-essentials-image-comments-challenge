//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class ImageCommentsMapper {
	private struct Root: Decodable {
		private let items: [RemoteImageComment]

		private struct RemoteImageComment: Decodable {
			struct Author: Decodable {
				let username: String
			}

			let id: UUID
			let message: String
			let created_at: Date
			let author: Author
		}

		var comments: [ImageComment] {
			items.map {
				ImageComment(
					id: $0.id,
					message: $0.message,
					createdAt: $0.created_at,
					authorUserName: $0.author.username
				)
			}
		}
	}

	public enum Error: Swift.Error {
		case invalidData
	}

	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601

		guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
			throw Error.invalidData
		}

		return root.comments
	}

	private static func isOK(_ response: HTTPURLResponse) -> Bool {
		return (200 ... 299).contains(response.statusCode)
	}
}

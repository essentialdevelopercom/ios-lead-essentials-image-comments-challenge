
import Foundation

public final class ImageCommentsMapper {
	private struct Root: Decodable {
		private let items: [RemoteImageCommentItem]

		private struct RemoteImageCommentItem: Decodable {
			let id: UUID
			let message: String
			let created_at: Date
			let author: RemoteAuthorItem
		}

		private struct RemoteAuthorItem: Decodable {
			let username: String
		}

		var comments: [ImageComment] {
			items.map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: Author(username: $0.author.username)) }
		}
	}

	public enum Error: Swift.Error {
		case invalidData
	}

	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601

		guard ImageCommentsMapper.isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
			throw Error.invalidData
		}

		return root.comments
	}

	private static func isOK(_ response: HTTPURLResponse) -> Bool {
		200 ... 299 ~= response.statusCode
	}
}

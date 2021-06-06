
import Foundation

public struct ImageComment: Equatable {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let author: Author

	public init(id: UUID, message: String, createdAt: Date, author: Author) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}

	public static func == (lhs: ImageComment, rhs: ImageComment) -> Bool {
		lhs.id == rhs.id
	}
}

public struct Author {
	public let username: String

	public init(username: String) {
		self.username = username
	}
}

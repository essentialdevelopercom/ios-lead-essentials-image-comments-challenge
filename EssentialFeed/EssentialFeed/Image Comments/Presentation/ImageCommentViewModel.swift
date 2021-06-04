//
// Copyright © 2021 Essential Developer. All rights reserved.
//

public struct ImageCommentViewModel: Equatable {
	public let message: String
	public let createdAt: String
	public let username: String

	public init(message: String, createdAt: String, username: String) {
		self.message = message
		self.createdAt = createdAt
		self.username = username
	}
}

//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Equatable {
	public let id: UUID
	public let message: String
	public let created_at: Date
	public let username: String

	public init(id: UUID, message: String, createdAt: Date, username: String) {
		self.id = id
		self.message = message
		self.created_at = createdAt
		self.username = username
	}
}

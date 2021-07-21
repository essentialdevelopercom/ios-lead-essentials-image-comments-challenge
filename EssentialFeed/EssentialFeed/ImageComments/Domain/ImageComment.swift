//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Equatable {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let authorUserName: String

	public init(id: UUID, message: String, createdAt: Date, authorUserName: String) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.authorUserName = authorUserName
	}
}

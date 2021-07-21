//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentViewModel: Equatable, Hashable {
	public let username: String
	public let createdAt: String
	public let message: String

	public init(username: String, createdAt: String, message: String) {
		self.username = username
		self.createdAt = createdAt
		self.message = message
	}
}

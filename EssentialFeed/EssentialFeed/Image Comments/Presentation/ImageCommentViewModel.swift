//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentViewModel: Hashable {
	public let message: String
	public let date: String
	public let username: String

	public init(message: String, date: String, username: String) {
		self.message = message
		self.date = date
		self.username = username
	}
}

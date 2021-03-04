//
//  Comment+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Robert Dates on 3/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import Foundation

extension Comment {
	public init(id: UUID, message: String, createdAt: Date, username: String) {
		self.init(id: id, message: message, createdAt: createdAt, author: Author(username: username))
	}
}

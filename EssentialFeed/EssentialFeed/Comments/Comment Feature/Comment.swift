//
//  Comment.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/21/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct Comment: Hashable {
	
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
	
	public init(id: UUID, message: String, createdAt: Date, username: String) {
		self.init(id: id, message: message, createdAt: createdAt, author: Author(username: username))
	}
}

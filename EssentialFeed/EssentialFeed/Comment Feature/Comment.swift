//
//  Comment.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 3/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct Comment {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let author: CommentAuthor
	
	public init(id: UUID, message: String, createdAt: Date, author: CommentAuthor) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
}

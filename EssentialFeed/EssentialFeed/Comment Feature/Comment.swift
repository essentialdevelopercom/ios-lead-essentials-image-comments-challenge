//
//  Comment.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct Comment: Equatable {
	public let id: UUID
	public let message: String
	public let createdAt: String
	public let author: CommentAuthor
	
	public init(id: UUID, message: String, createdAt: String, author: CommentAuthor) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
}

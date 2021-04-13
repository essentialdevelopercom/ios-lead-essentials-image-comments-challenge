//
//  Comment.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 3/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Equatable {
	public let id: UUID
	public let message: String
	public let createdAt: String
	public let author: ImageCommentAuthor
	
	public init(id: UUID, message: String, createdAt: String, author: ImageCommentAuthor) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
}

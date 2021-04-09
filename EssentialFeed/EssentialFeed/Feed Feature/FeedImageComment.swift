//
//  FeedImageComment.swift
//  EssentialFeed
//
//  Created by Ivan Ornes on 10/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageComment: Hashable {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let author: FeedImageCommentAuthor
	
	public init(id: UUID, message: String, createdAt: Date, author: FeedImageCommentAuthor) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
}

//
//  FeedComment.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedComment: Hashable {
	let id: UUID
	let message: String
	let createdAt: Date
	let author: FeedCommentAuthor
	
	public init(id: UUID, message: String, createdAt: Date, author: FeedCommentAuthor) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
	
}

public struct FeedCommentAuthor: Hashable {
	let username: String
	
	public init(username: String) {
		self.username = username
	}
}

//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Equatable, Hashable {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let author: ImageCommentAuthor
	
	public init(id: UUID, message: String, createdAt: Date, author: ImageCommentAuthor) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
}

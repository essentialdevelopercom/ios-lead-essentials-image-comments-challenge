//
//  Comment.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct Comment: Hashable {
	
	public let id: UUID
	public let message: String
	public let createAt: Date
	public let author: CommentAuthor
	
	public init(id: UUID, message: String, createAt: Date, author: CommentAuthor) {
		self.id = id
		self.message = message
		self.createAt = createAt
		self.author = author
	}
}

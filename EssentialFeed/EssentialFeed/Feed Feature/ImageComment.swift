//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 03/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Hashable {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let author: Author
	
	public struct Author: Hashable {
		public let username: String
		
		public init(username: String) {
			self.username = username
		}
	}
	
	public init(id: UUID, message: String, createdAt: Date, author: ImageComment.Author) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
}

//
//  FeedImageComment.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageComment: Equatable {
	
	public struct Author: Equatable {
		public let username: String
		
		public init(username: String) {
			self.username = username
		}
	}
	
	public let id: UUID
	public let message: String
	public let createdAt: String
	public let author: Author
	
	public init(id: UUID, message: String, createdAt: String, author: Author) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
}

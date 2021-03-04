//
//  RemoteImageComment.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 04/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct RemoteImageComment: Decodable {
	public let id: UUID
	public let message: String
	public let created_at: Date
	public let author: Author
	
	public struct Author: Decodable {
		public let username: String
		
		public init(username: String) {
			self.username = username
		}
	}
	
	public init(id: UUID, message: String, created_at: Date, author: RemoteImageComment.Author) {
		self.id = id
		self.message = message
		self.created_at = created_at
		self.author = author
	}
}

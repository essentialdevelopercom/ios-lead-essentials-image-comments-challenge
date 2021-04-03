//
//  Comment.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct Comment: Hashable {
		
	public let id: UUID
	public let message: String
	public let createdAt: String
	public let author: String
	
	public init(id: UUID, message: String, createdAt: String, author: String) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
}

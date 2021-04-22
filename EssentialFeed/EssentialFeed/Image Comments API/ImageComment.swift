//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 4/22/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Equatable {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let username: String

	public init(id: UUID, message: String, createdAt: Date, username: String) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.username = username
	}
}

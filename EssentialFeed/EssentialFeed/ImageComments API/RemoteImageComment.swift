//
//  RemoteImageComment.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 27.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct RemoteImageComment: Decodable, Equatable {
	public init(id: UUID, message: String, createdAt: Date, author: RemoteImageCommentAuthor) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}

	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let author: RemoteImageCommentAuthor
}

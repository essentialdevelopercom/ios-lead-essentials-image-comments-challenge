//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 20/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Hashable {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let author: ImageCommentAuthor
	
	public init(id: UUID, message: String, createdAt: Date, author: ImageCommentAuthor){
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
}


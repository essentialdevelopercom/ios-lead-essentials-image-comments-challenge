//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Alok Subedi on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Equatable {
	public let id: UUID
	public let message: String
	public let createdDate: Date
	public let author: CommentAuthor
	
	public init(id: UUID, message: String, createdDate: Date, author: CommentAuthor) {
		self.id = id
		self.message = message
		self.createdDate = createdDate
		self.author = author
	}
}

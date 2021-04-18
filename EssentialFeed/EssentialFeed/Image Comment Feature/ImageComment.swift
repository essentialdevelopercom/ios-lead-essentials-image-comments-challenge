//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Ángel Vázquez on 17/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageComment: Hashable {
	public let id: UUID
	public let message: String
	public let creationDate: Date
	public let author: String
	
	public init(id: UUID, message: String, creationDate: Date, author: String) {
		self.id = id
		self.message = message
		self.creationDate = creationDate
		self.author = author
	}
}

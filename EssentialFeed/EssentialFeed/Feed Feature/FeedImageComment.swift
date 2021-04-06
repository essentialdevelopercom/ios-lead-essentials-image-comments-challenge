//
//  FeedImageComment.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 04/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageComment: Equatable {
	public let id: UUID
	public let message: String
	public let creationDate: Date
	public let author: String
	
	public init(id: UUID, message: String, creationDate: Date, authorUsername: String) {
		self.id = id
		self.message = message
		self.creationDate = creationDate
		self.author = authorUsername
	}
}

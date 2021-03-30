//
//  PresentationImageComment.swift
//  EssentialFeed
//
//  Created by Danil Vassyakin on 3/31/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct PresentationImageComment: Hashable {
	public let message: String
	public let createdAt: String
	public let author: String
	
	public init(message: String, createdAt: String, author: String) {
		self.message = message
		self.createdAt = createdAt
		self.author = author
	}
}

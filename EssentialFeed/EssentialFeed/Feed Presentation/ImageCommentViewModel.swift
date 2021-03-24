//
//  ImageCommentViewModel.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentViewModel: Hashable {
	public let authorUsername: String
	public let createdAt: String
	public let message: String
	
	public init(authorUsername: String, createdAt: String, message: String) {
		self.authorUsername = authorUsername
		self.createdAt = createdAt
		self.message = message
	}
}

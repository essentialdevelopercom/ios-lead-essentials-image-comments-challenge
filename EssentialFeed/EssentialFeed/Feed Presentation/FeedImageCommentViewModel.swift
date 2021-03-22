//
//  FeedImageCommentViewModel.swift
//  EssentialFeed
//
//  Created by Ivan Ornes on 15/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageCommentViewModel {
	public let message: String
	public let creationDate: String
	public let author: String
	
	public init(message: String, creationDate: String, author: String) {
		self.message = message
		self.creationDate = creationDate
		self.author = author
	}
}

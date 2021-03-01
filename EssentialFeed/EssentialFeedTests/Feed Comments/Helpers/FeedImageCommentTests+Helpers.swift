//
//  FeedImageCommentTests+Helpers.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

func uniqueComment() -> FeedComment {
	.init(id: UUID(),
		  message: "a message",
		  createdAt: Date(),
		  author: .init(username: "danil")
	)
}

func uniqueComments() -> [FeedComment] {
	[uniqueComment(), uniqueComment()]
}

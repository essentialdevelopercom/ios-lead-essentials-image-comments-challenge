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
		  createdAt: Date(timeIntervalSince1970: 1617129798.219656),
		  author: .init(username: "danil")
	)
}

func uniqueComments() -> (comments: [FeedComment], presentation: [PresentationImageComment]) {
	let comments = [uniqueComment(), uniqueComment()]
	let presentation: [PresentationImageComment] = comments.map {
		PresentationImageComment(message: $0.message, createdAt: "31 марта 2021 г., 00:43", author: $0.author.username)
	}
	return (comments: comments, presentation: presentation)
}

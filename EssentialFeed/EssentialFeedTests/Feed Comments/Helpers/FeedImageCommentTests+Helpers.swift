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
		  createdAt: Date().adding(days: -1),
		  author: .init(username: "danil")
	)
}

func uniqueComments(locale: Locale = Locale(identifier: "en_US_POSIX")) -> (comments: [FeedComment], presentation: [PresentationImageComment]) {
	let comments = [uniqueComment(), uniqueComment()]
	let createdAt: String
	switch locale.identifier {
	case "ru_RU":
		createdAt = "1 день назад"
	default:
		createdAt = "1 day ago"
	}
	
	let presentation: [PresentationImageComment] = comments.map {
		PresentationImageComment(message: $0.message, createdAt: createdAt, author: $0.author.username)
	}
	return (comments: comments, presentation: presentation)
}

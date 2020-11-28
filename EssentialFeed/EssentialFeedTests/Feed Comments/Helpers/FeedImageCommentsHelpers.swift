//
//  FeedImageCommentsHelpers.swift
//  EssentialFeedTests
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

func makeCommentItem(id: UUID = UUID(), message: String = "Any message", createdAt: Date = Date(), author name: String = "Author Name") -> (codableItem: CodableFeedImageComment, item: ImageComment) {
	let author = CodableFeedImageComment.Author(username: name)
	let codableItem = CodableFeedImageComment(id: id, message: message, created_at: createdAt, author: author)
	let item = ImageComment(id: codableItem.id, message: codableItem.message, createdAt: codableItem.created_at, author: codableItem.author.username)
	return (codableItem, item)
}

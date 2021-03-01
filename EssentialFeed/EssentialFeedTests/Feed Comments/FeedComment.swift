//
//  FeedComment.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct FeedComment: Hashable {
	let id: UUID
	let message: String
	let createdAt: String
	let author: FeedCommentAuthor
}

struct FeedCommentAuthor: Hashable {
	let username: String
}

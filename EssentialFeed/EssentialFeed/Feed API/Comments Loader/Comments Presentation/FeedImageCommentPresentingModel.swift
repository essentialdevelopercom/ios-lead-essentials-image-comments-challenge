//
//  FeedImageCommentPresentingModel.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/29/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageCommentPresentingModel: Hashable {
	
	public let username: String
	public let creationTime: String
	public let comment: String
	
	public init(username: String, comment: String, creationTime: String) {
		self.username = username
		self.comment = comment
		self.creationTime = creationTime
	}
}

public extension Array where Element == ImageComment {
	func toModels() -> [FeedImageCommentPresentingModel] {
		map { FeedImageCommentPresentingModel(username: $0.author, comment: $0.message, creationTime: $0.createdAt.timeAgoDisplay()) }
	}
}

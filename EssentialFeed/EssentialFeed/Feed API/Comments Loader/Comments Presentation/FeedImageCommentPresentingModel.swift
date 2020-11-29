//
//  FeedImageCommentPresentingModel.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/29/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageCommentPresentingModel: Hashable {
	
	let username: String
	let creationTime: String
	let comment: String
	
	public init(username: String, comment: String, creationTime: String) {
		self.username = username
		self.comment = comment
		self.creationTime = creationTime
	}
}

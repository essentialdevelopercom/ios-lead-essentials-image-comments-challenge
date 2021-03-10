//
//  FeedImageCommentAuthor.swift
//  EssentialFeed
//
//  Created by Ivan Ornes on 10/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageCommentAuthor: Hashable {
	public let username: String
	
	public init(username: String) {
		self.username = username
	}
}

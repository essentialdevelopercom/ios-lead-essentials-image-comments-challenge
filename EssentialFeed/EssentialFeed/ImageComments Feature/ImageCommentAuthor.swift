//
//  CommentAuthor.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentAuthor: Equatable, Hashable {
	public let username: String
	
	public init(username: String) {
		self.username = username
	}
}
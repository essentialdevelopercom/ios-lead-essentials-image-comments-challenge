//
//  ImageCommentAuthor.swift
//  EssentialFeed
//
//  Created by Cronay on 17.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

public struct ImageCommentAuthor: Hashable {
	public let username: String

	public init(username: String) {
		self.username = username
	}
}

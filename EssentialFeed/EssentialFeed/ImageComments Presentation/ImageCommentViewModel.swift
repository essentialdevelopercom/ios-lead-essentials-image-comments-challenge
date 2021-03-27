//
//  ImageCommentViewModel.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/10/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct ImageCommentViewModel: Hashable {
	public let message: String
	public let created: String
	public let username: String
	
	public init(message: String, created: String, username: String) {
		self.message = message
		self.created = created
		self.username = username
	}
}

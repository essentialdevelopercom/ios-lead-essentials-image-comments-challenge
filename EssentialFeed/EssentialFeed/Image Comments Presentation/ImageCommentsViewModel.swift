//
//  ImageCommentsViewModel.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 19/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct ImageCommentViewModel: Hashable {
	public let message: String
	public let date: String
	public let username: String

	public init(
		message: String,
		date: String,
		username: String
	) {
		self.message = message
		self.date = date
		self.username = username
	}
}

public struct ImageCommentsViewModel {
	public let comments: [ImageCommentViewModel]
}

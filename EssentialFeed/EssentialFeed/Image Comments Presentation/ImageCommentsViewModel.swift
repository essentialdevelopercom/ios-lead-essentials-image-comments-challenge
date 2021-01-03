//
//  ImageCommentsViewModel.swift
//  EssentialFeed
//
//  Created by Araceli Ruiz Ruiz on 06/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
	
	public init(comments: [ImageCommentViewModel]) {
		self.comments = comments
	}
}

public struct ImageCommentViewModel: Equatable {
	public let message: String
	public let date: String
	public let username: String
	
	public init(message: String, date: String, username: String) {
		self.message = message
		self.date = date
		self.username = username
	}
}

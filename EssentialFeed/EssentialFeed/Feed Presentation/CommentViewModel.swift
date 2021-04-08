//
//  CommentViewModel.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 11.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct CommentListViewModel {
	public let comments: [CommentViewModel]
}

public struct CommentViewModel: Hashable {
	public let message: String
	public let author: String
	public let date: String
	
	public init(message: String, author: String, date: String) {
		self.message = message
		self.author = author
		self.date = date
	}
}

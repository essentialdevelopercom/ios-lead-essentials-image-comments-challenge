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

public struct CommentViewModel {
	public let message: String
	public let author: String
	public let date: String
}

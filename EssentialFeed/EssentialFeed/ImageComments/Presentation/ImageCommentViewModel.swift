//
//  ImageCommentViewModel.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct ImageCommentViewModel: Hashable {
	public let message: String?
	public let username: String?
	public let createdAt: String?

	public init(message: String?, username: String?, createdAt: String?) {
		self.message = message
		self.username = username
		self.createdAt = createdAt
	}
}

//
//  PresentableImageComment.swift
//  EssentialFeed
//
//  Created by Cronay on 21.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

public struct PresentableImageComment: Hashable {
	public let username: String
	public let message: String
	public let date: String

	public init(username: String, message: String, date: String) {
		self.username = username
		self.message = message
		self.date = date
	}
}

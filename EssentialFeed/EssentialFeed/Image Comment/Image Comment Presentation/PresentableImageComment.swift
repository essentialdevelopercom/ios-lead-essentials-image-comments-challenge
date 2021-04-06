//
//  PresentableImageComment.swift
//  EssentialFeed
//
//  Created by alok subedi on 05/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
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

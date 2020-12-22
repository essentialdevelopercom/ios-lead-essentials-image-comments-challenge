//
//  PresentableImageComment.swift
//  EssentialFeed
//
//  Created by Cronay on 21.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct PresentableImageComment: Hashable {
	let username: String
	let message: String
	let date: String

	public init(username: String, message: String, date: String) {
		self.username = username
		self.message = message
		self.date = date
	}
}

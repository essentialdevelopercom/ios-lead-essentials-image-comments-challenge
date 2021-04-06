//
//  PresentableComment.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/24/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct PresentableComment: Hashable {
	public let username: String
	public let message: String
	public let date: String

	public init(username: String, message: String, date: String) {
		self.username = username
		self.message = message
		self.date = date
	}
}

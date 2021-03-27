//
//  ImageCommentAuthor.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 27.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentAuthor: Decodable, Equatable {
	public init(username: String) {
		self.username = username
	}

	public let username: String
}

//
//  CommentAuthor.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 3/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct CommentAuthor: Equatable {
	public let username: String
	
	public init(username: String) {
		self.username = username
	}
}

//
//  CommentAuthor.swift
//  EssentialFeed
//
//  Created by Alok Subedi on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

public struct CommentAuthor: Equatable {
	public let username: String
	
	public init(username: String) {
		self.username = username
	}
}

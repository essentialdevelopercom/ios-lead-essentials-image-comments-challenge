//
//  ImageCommentAuthor.swift
//  EssentialFeed
//
//  Created by Bogdan Poplauschi on 27/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentAuthor: Equatable {
	public let username: String
	
	public init(username: String) {
		self.username = username
	}
}

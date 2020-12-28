//
//  RemoteCommentAuthor.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteCommentAuthor: Decodable {
	let username: String
	
	func toModel() -> CommentAuthor {
		return CommentAuthor(username: username)
	}
}

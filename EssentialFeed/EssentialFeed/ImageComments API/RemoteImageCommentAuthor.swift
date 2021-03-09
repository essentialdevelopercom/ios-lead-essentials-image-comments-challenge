//
//  RemoteCommentAuthor.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

struct RemoteImageCommentAuthor: Decodable {
	public let username: String
	
	var local: ImageCommentAuthor {
		return ImageCommentAuthor(username: username)
	}
}

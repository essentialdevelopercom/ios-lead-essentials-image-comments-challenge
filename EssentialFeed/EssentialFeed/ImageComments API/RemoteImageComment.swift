//
//  RemoteComment.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageComment: Decodable {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let author: RemoteImageCommentAuthor
	
	enum CodingKeys: String, CodingKey {
		case id
		case message
		case createdAt = "created_at"
		case author
	}
	
	var local: ImageComment {
		return ImageComment(id: id, message: message, createdAt: createdAt, author: author.local)
	}
}
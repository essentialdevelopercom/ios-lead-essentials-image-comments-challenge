//
//  Comment.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct Comment: Equatable {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let author: CommentAuthor
}

extension Comment: Decodable {
	enum CodingKeys: String, CodingKey {
		case id
		case message
		case createdAt = "created_at"
		case author
	}
}

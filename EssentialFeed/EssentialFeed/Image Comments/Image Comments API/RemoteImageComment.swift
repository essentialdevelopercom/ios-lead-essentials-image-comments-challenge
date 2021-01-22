//
//  RemoteImageComment.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 20/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageComment: Decodable {
	let id: UUID
	let message: String
	let createdAt: Date
	let author: RemoteImageCommentAuthor
	
	enum CodingKeys: String, CodingKey{
		case id
		case message
		case createdAt = "created_at"
		case author
	}
}

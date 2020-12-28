//
//  RemoteComment.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteComment: Decodable {
	let id: UUID
	let message: String
	let createAt: Date
	let author: RemoteCommentAuthor
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case message = "message"
		case createAt = "created_at"
		case author = "author"
	}
}

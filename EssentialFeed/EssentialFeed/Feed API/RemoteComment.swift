//
//  RemoteComment.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 05.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteComment: Decodable {
	struct Author: Decodable {
		let username: String
	}
	
	enum CodingKeys: String, CodingKey {
		case id
		case message
		case createdAt = "created_at"
		case author
	}
	
	let id: UUID
	let message: String
	let createdAt: Date
	let author: Author
}

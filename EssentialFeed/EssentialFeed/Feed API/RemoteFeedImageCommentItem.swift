//
//  RemoteFeedImageCommentItem.swift
//  EssentialFeed
//
//  Created by Ivan Ornes on 10/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteFeedImageCommentItem: Decodable {
	let id: UUID
	let message: String
	let createdAt: String
	let author: RemoteFeedImageCommentItemAuthor
	
	enum CodingKeys: String, CodingKey {
		case id
		case message
		case createdAt = "created_at"
		case author
	}
}

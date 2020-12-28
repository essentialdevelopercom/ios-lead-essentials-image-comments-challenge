//
//  CommentItemMapper.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

class CommentItemMapper {
	private struct Root: Decodable {
		public let items: [RemoteComment]
	}
	
	static func map(_ data: Data, _ response: HTTPURLResponse) throws-> [RemoteComment] {
		guard response.statusCode == 200 else {
			throw RemoteCommentLoader.Error.invalidData
		}
		
		guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteCommentLoader.Error.invalidData
		}
		
		return root.items
	}
}

struct RemoteComment: Decodable {
	let id: UUID
	let message: String
	let createAt: Date
	let author: RemoteCommentAuthor
}

struct RemoteCommentAuthor: Decodable {
	let username: String
	
	func toModel() -> CommentAuthor {
		return CommentAuthor(username: username)
	}
}



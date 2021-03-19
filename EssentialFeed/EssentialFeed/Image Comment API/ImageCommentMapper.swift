//
//  ImageCommentMapper.swift
//  EssentialFeed
//
//  Created by Ángel Vázquez on 19/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct ImageCommentMapper {
	private struct Root: Decodable {
		let items: [RemoteImageComment]
	}
	
	private struct RemoteImageComment: Decodable {
		struct Author: Decodable {
			let username: String
		}
		
		let id: UUID
		let message: String
		let createdAt: Date
		let author: Author
		
		var imageComment: ImageComment {
			ImageComment(id: id, message: message, creationDate: createdAt, author: author.username)
		}
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
		guard response.isWithinSuccessStatusCodes,
			  let root = try? JSONDecoder()
				.withKeyDecodingStrategy(.convertFromSnakeCase)
				.withDateDecodingStrategy(.iso8601)
				.decode(Root.self, from: data) else {
			throw RemoteImageCommentLoader.Error.invalidData
		}
		
		return root.items.map(\.imageComment)
	}
}

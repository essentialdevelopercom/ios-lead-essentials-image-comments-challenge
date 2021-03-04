//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Alok Subedi on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

class ImageCommentsMapper {
	private struct Root: Decodable {
		let items: [RemoteImageComment]
		
		var imageComments: [ImageComment] {
			return items.map { ImageComment(id: $0.id, message: $0.message, createdDate: $0.created_at, author: CommentAuthor(username: $0.author.username))}
		}
	}
	
	private struct RemoteImageComment: Decodable {
		let id: UUID
		let message: String
		let created_at: Date
		let author: RemoteCommentAuthor
	}
	
	private struct RemoteCommentAuthor: Decodable {
		let username: String
	}
	
	static func map(data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
		let jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = .iso8601
		guard response.is2xxOK, let root = try? jsonDecoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}
		
		return root.imageComments
	}
}


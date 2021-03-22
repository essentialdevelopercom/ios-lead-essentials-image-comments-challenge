//
//  RemoteImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 04/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageCommentsMapper {
	private struct Root: Decodable {
		let items: [Item]
		
		struct Item: Decodable {
			let id: UUID
			let message: String
			let created_at: Date
			let author: Author
		}
		
		struct Author: Decodable {
			let username: String
		}
		
		var comments: [ImageComment] {
			items.map{
				ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, username: $0.author.username)
			}
		}

	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		guard response.isOK,
			  let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}
		
		return root.comments
	}
}

//
//  ImageCommentsItemsMapper.swift
//  EssentialFeed
//
//  Created by Rakesh Ramamurthy on 01/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageCommentAuthor: Decodable {
	let username: String
}

struct RemoteImageCommentItem: Decodable {
	let id: UUID
	let message: String
	let created_at: Date
	let author: RemoteImageCommentAuthor
}

class ImageCommentsItemsMapper {
	private static var OK_HTTP_200: Int { return 200 }
	
	struct Root: Decodable {
		let items: [RemoteImageCommentItem]
	}

	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageCommentItem] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		guard response.statusCode == OK_HTTP_200,
			  let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}
		return root.items
	}
}

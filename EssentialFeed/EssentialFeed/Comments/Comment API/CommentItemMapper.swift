//
//  CommentItemMapper.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/21/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

internal final class CommentItemMapper {
	private struct Root: Decodable {
		let items: [RemoteCommentItem]
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteCommentItem] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		guard response.statusCode >= 200, response.statusCode <= 299, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteCommentLoader.Error.invalidData
		}
		return root.items
	}
	
}

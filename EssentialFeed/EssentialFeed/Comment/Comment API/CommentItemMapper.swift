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
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		guard response.statusCode == 200, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteCommentLoader.Error.invalidData
		}
		
		return root.items
	}
}

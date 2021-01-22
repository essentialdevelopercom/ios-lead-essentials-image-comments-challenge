//
//  CommentItemMapper.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/21/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class CommentItemMapper {
	private struct Root: Decodable {
		let items: [RemoteCommentItem]
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteCommentItem] {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteCommentLoader.Error.invalidData
		}
		
		return root.items
	}
	
}

//
//  RemoteCommentMapper.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

final class RemoteCommentMapper {
	
	private struct Root: Decodable {
		let items: [RemoteComment]
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteComment] {
		guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteCommentLoader.Error.invalidData
		}
		
		return root.items
	}
	
}
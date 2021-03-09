//
//  RemoteCommentMapper.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

final class ImageCommentMapper {
	
	private struct Root: Decodable {
		let items: [RemoteImageComment]
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		guard response.isOK, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentLoader.Error.invalidData
		}
		
		return root.items
	}
	
}

//
//  ImageCommentMapper.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 3/16/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class ImageCommentMapper {
	private struct Root: Decodable {
		let items: [RemoteImageComment]
	}

	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		guard response.statusCode == 200, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentLoader.Error.invalidData
		}
		
		return root.items
	}
}

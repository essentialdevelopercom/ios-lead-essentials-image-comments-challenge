//
//  ImageCommentItemsMapper.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 27.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

final class ImageCommentItemsMapper {
	private struct Root: Decodable {
		let items: [RemoteImageComment]
	}

	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageComment] {
		guard response.statusCode == 200 else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		guard let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}

		return root.items
	}
}

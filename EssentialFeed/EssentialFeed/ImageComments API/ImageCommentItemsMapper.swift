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

	private static var decoder: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}

	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageComment] {
		guard response.isOK, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}

		return root.items
	}
}

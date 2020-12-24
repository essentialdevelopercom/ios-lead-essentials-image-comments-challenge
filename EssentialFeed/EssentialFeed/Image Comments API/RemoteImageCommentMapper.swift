//
//  RemoteImageCommentMapper.swift
//  EssentialFeed
//
//  Created by Cronay on 17.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

final class RemoteImageCommentMapper {

	private static let jsonDecoder: JSONDecoder = {
		let jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = .iso8601
		return jsonDecoder
	}()

	private struct Root: Decodable {
		let items: [RemoteImageCommentItem]
	}

	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageCommentItem] {
		if response.isInSuccessRange, let root = try? jsonDecoder.decode(Root.self, from: data) {
			return root.items
		} else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}
	}
}

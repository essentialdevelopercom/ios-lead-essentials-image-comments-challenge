//
//  FeedImageCommentMapper.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 08/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

internal class FeedImageCommentMapper {
	private struct Root: Decodable {
		let items: [RemoteFeedImageComment]
	}
		
	internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		guard 200 ..< 300 ~= response.statusCode, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteFeedImageCommentLoader.Error.invalidData
		}
		
		return root.items
	}
}

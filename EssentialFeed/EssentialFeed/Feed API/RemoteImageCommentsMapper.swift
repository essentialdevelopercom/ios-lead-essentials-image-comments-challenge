//
//  RemoteImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 04/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

struct RemoteImageCommentsMapper {
	private struct Root: Decodable {
		let items: [RemoteImageComment]
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageComment] {
		guard response.isOK,
			  let root = try? iso8601Decoder().decode(Root.self, from: data) else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}
		
		return root.items
	}
	
	private static func iso8601Decoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}
}

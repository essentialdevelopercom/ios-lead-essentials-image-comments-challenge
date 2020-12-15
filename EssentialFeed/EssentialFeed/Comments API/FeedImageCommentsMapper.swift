//
//  FeedImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import Foundation

struct DecodableFeedImageComment: Decodable {
	
	struct Author: Decodable {
		let username: String
	}
	
	let id: UUID
	let message: String
	let created_at: Date
	let author: Author
}

final class FeedImageCommentsMapper {
	
	struct Root: Decodable {
		let items: [DecodableFeedImageComment]
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [DecodableFeedImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		guard (200...299).contains(response.statusCode), let root = try? decoder.decode(Root.self, from: data)
		else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return root.items
	}
}

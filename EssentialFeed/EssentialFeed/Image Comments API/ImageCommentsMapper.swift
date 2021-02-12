//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 10/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public enum ImageCommentsMapper {
	private struct Root: Decodable {

		private struct Item: Decodable {
			let id: UUID
			let message: String
			let created_at: Date
			let author: Author
		}

		private struct Author: Decodable {
			let username: String
		}

		private let items: [Item]

		var comments: [ImageComment] {
			items.map {
				ImageComment(
					id: $0.id,
					message: $0.message,
					createdAt: $0.created_at,
					username: $0.author.username
				)
			}
		}
	}
	
	public enum Error: Swift.Error {
		case invalidData
	}
	
	public static func map(
		_ data: Data,
		from response: HTTPURLResponse
	) throws -> [ImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601

		guard response.isOK, let root = try? decoder.decode(Root.self, from: data) else {
			throw Error.invalidData
		}

		return root.comments
	}
}

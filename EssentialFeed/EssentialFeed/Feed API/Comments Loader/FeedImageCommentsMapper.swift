//
//  FeedImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import Foundation

public struct CodableFeedImageComment: Codable {
	
	public struct Author: Codable, Equatable {

		public let username: String
		
		public init(username: String) {
			self.username = username
		}
	}
	
	public let id: UUID
	public let message: String
	public let created_at: Date
	public let author: Author
	
	public init(id: UUID, message: String, created_at: Date, author: CodableFeedImageComment.Author) {
		self.id = id
		self.message = message
		self.created_at = created_at
		self.author = author
	}
}

public final class FeedImageCommentsMapper {
	
	public struct Root: Codable {

		let items: [CodableFeedImageComment]
		
		public init(items: [CodableFeedImageComment]) {
			self.items = items
		}
	}
	
	public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [CodableFeedImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		guard response.isOK, let root = try? decoder.decode(Root.self, from: data)
		else {
			throw RemoteFeedLoader.Error.invalidData
		}
		return root.items
	}
}

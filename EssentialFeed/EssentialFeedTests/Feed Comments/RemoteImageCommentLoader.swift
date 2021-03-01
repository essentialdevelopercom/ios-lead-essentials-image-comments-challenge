//
//  RemoteImageCommentLoader.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

class RemoteImageCommentLoader {
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	typealias Result = Swift.Result<[FeedComment], Error>
	
	private let imageUrlProvider: ((String) -> URL)
	private let client: HTTPClient
	
	init(imageUrlProvider: @escaping ((String) -> URL), client: HTTPClient) {
		self.imageUrlProvider = imageUrlProvider
		self.client = client
	}
	
	func load(imageId: String, completion: @escaping (Result) -> Void) {
		let url = imageUrlProvider(imageId)
		client.get(from: url, completion: { result in
			switch result {
			case let .success(result):
				do {
					let comments = try RemoteImageCommentMapper.map(result.0, from: result.1)
					completion(.success(comments.toModels()))
				} catch {
					completion(.failure(.invalidData))
				}
			case .failure:
				completion(.failure(.connectivity))
			}
		})
	}
	
}

struct RemoteImageCommentMapper {
	
	struct RemoteFeedComment: Codable {
		
		enum CodingKeys: String, CodingKey {
			case id, message, createdAt = "created_at", author
		}
		
		let id: UUID
		let message: String
		let createdAt: Date
		let author: RemoteFeedCommentAuthor
		
		init(id: UUID, message: String, createdAt: Date, author: RemoteImageCommentMapper.RemoteFeedCommentAuthor) {
			self.id = id
			self.message = message
			self.createdAt = createdAt
			self.author = author
		}
		
	}
	
	struct RemoteFeedCommentAuthor: Codable {
		let username: String
	}
	
	private struct Root: Decodable {
		let items: [RemoteFeedComment]
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		guard response.isOK, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentLoader.Error.invalidData
		}
		return root.items
	}
	
}

private extension Array where Element == RemoteImageCommentMapper.RemoteFeedComment {
	func toModels() -> [FeedComment] {
		self.map {
			let author = FeedCommentAuthor(username: $0.author.username)
			return FeedComment(id: $0.id, message: $0.message, createdAt: $0.createdAt, author: author)
		}
	}
}


//TODO: remove when move from test target
extension HTTPURLResponse {
	private static var OK_200: Int { return 200 }
	
	var isOK: Bool {
		return statusCode == HTTPURLResponse.OK_200
	}
}

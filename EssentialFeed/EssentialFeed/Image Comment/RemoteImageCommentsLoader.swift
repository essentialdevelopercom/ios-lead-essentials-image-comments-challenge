//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Alok Subedi on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentsLoader {
	public typealias Result = Swift.Result<[ImageComment], Error>
	
	private struct Root: Decodable {
		let items: [RemoteImageComment]
		
		var imageComments: [ImageComment] {
			return items.map { ImageComment(id: $0.id, message: $0.message, createdDate: $0.created_at, author: CommentAuthor(username: $0.author.username))}
		}
	}
	
	private struct RemoteImageComment: Decodable {
		let id: UUID
		let message: String
		let created_at: Date
		let author: RemoteCommentAuthor
	}
	
	private struct RemoteCommentAuthor: Decodable {
		let username: String
	}
	
	private let client: HTTPClient
	private let url: URL
	
	public init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { [weak self] result  in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				if response.statusCode == 200 {
					let jsonDecoder = JSONDecoder()
					jsonDecoder.dateDecodingStrategy = .iso8601
					do {
					let root = try jsonDecoder.decode(Root.self, from: data)
						completion(.success(root.imageComments))
					} catch {
						completion(.failure(.invalidData))
					}
				} else {
					completion(.failure(.invalidData))
				}
			case .failure:
				completion(.failure(.connectivity))
			}
		}
	}
}

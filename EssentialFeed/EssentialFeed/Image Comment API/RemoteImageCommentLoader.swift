//
//  RemoteImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Ángel Vázquez on 19/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentLoader: ImageCommentLoader {
	
	public typealias Result = ImageCommentLoader.Result
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	private let client: HTTPClient
	
	public init(client: HTTPClient) {
		self.client = client
	}
	
	public func load(from url: URL, completion: @escaping (Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				do {
					let comments = try ImageCommentMapper.map(data, from: response)
					completion(.success(comments))
				} catch {
					completion(.failure(error))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

struct ImageCommentMapper {
	
	private static var acceptedStatusCodeRange = 200..<300
	
	private struct Root: Decodable {
		let items: [RemoteImageComment]
	}
	
	private struct RemoteImageComment: Decodable {
		struct Author: Decodable {
			let username: String
		}
		
		let id: UUID
		let message: String
		let createdAt: Date
		let author: Author
		
		var imageComment: ImageComment {
			ImageComment(id: id, message: message, creationDate: createdAt, author: author.username)
		}
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
		guard acceptedStatusCodeRange.contains(response.statusCode) else {
			throw RemoteImageCommentLoader.Error.invalidData
		}
		
		let jsonDecoder = JSONDecoder()
		jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
		jsonDecoder.dateDecodingStrategy = .iso8601
		
		guard let root = try? jsonDecoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentLoader.Error.invalidData
		}
		
		return root.items.map(\.imageComment)
	}
}

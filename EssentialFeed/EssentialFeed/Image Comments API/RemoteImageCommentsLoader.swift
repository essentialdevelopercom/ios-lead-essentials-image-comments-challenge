//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 20/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation


public final class RemoteImageCommentsLoader{
	private let client: HTTPClient
	private let url: URL
	
	public typealias Result = Swift.Result<[ImageComment], RemoteImageCommentsLoader.Error>
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(client: HTTPClient, url: URL){
		self.client = client
		self.url = url
	}
	
	public func load(completion: @escaping (Result) -> Void){
		client.get(from: url){ result in
			switch result{
			case .success((let data, let response)):
				completion(RemoteImageCommentsLoader.map(data, from: response))
			case .failure(_):
				completion(.failure(RemoteImageCommentsLoader.Error.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try DataMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(Error.invalidData)
		}
	}
}


private final class DataMapper{
	struct Root: Decodable{
		let items: [RemoteImageComment]
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		guard response.isOK, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}
		
		return root.items
	}
}


private extension Array where Element == RemoteImageComment {
	func toModels() -> [ImageComment] {
		return map {ImageComment(id: $0.id, message: $0.message, createdAt: $0.createdAt, author: ImageCommentAuthor(username: $0.author.username))}
	}
}

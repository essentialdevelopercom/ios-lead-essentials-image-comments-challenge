//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Lukas Bahrle Santana on 20/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation


private struct Root: Decodable{
	let items: [RemoteImageComment]
}

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
				if response.statusCode != 200 {
					completion(.failure(.invalidData))
				}
				else{
					let decoder = JSONDecoder()
					decoder.dateDecodingStrategy = .iso8601
					if let decodedRoot = try? decoder.decode(Root.self, from: data){
						completion(.success(decodedRoot.items.toModels()))
					}
					else{
						completion(.failure(.invalidData))
					}
				}
			case .failure(_):
				completion(.failure(.connectivity))
			}
		}
	}
}

private extension Array where Element == RemoteImageComment {
	func toModels() -> [ImageComment] {
		return map {ImageComment(id: $0.id, message: $0.message, createdAt: $0.createdAt, author: ImageCommentAuthor(username: $0.author.username))}
	}
}

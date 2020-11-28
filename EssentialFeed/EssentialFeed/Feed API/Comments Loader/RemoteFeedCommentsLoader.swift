//
//  RemoteFeedCommentsLoader.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedCommentsLoader {
	
	public typealias Result = Swift.Result<[ImageComment], Error>
	
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	@discardableResult
	public func load(completion: @escaping (Result) -> Void) -> HTTPClientTask {
		return client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			
			switch result {
			case let .success((data, response)):
				completion(RemoteFeedCommentsLoader.map(data, from: response))
			case .failure(_):
				completion(.failure(.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try FeedImageCommentsMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(.invalidData)
		}
	}
}

private extension Array where Element == CodableFeedImageComment {
	 func toModels() -> [ImageComment] {
		 map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: $0.author.username) }
	 }
 }

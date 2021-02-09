//
//  RemoteFeedImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 05/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteFeedImageCommentLoader: FeedImageCommentLoader {
	private let client: HTTPClient
	
	public init(client: HTTPClient) {
		self.client = client
	}
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = FeedImageCommentLoader.Result
	
	private final class HTTPClientTaskWrapper: FeedImageCommentLoaderTask {		
		var wrapped: HTTPClientTask?

		func cancel() {
			wrapped?.cancel()
		}
	}
	
	public func loadImageCommentData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageCommentLoaderTask {
		let task = HTTPClientTaskWrapper()
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			
			switch result {
			case let .success((data, response)):
				completion(RemoteFeedImageCommentLoader.map(data, from: response))
				
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
		return task
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try FeedImageCommentMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(error)
		}
	}
}

private extension Array where Element == RemoteFeedImageComment {
	func toModels() -> [FeedImageComment] {
		return map { FeedImageComment(id: $0.id, message: $0.message, creationDate: $0.created_at, authorUsername: $0.author.username)}
	}
}

internal class FeedImageCommentMapper {
	private struct Root: Decodable {
		let items: [RemoteFeedImageComment]
	}
		
	internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		guard response.isOK, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteFeedImageCommentLoader.Error.invalidData
		}
		
		return root.items
	}
}

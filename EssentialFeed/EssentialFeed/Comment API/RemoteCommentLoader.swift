//
//  RemoteCommentLoader.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteCommentLoader {
	
	private let url: URL
	private let client: HTTPClient
	
	public typealias Result = Swift.Result<[Comment], Swift.Error>
	public enum Error: Swift.Error, Equatable {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
			switch result {
			case let .success((data, response)):
				completion(RemoteCommentLoader.map(data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try RemoteCommentMapper.map(data, from: response)
			return .success(items.toLocal())
		} catch {
			return .failure(error)
		}
	}
	
}

private extension Array where Element == RemoteComment {
	func toLocal() -> [Comment] {
		return map { $0.local }
	}
}

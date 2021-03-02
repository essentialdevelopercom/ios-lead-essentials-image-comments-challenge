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
	
	public typealias Result = Swift.Result<[Comment], Error>
	public enum Error: Swift.Error, Equatable {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				completion(RemoteCommentLoader.map(data, from: response))
			case .failure:
				completion(.failure(.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data)  {
			return .success(root.items)
		} else {
			return .failure(.invalidData)
		}
	}
	
	private struct Root: Decodable {
		let items: [Comment]
	}
	
}

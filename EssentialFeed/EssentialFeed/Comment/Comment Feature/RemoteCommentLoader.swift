//
//  RemoteCommentLoader.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol CommentLoader {
	typealias Result = Swift.Result<[Comment], Error>
	
	func load(completion: @escaping (Result) -> Void)
}

public class RemoteCommentLoader: CommentLoader {
	
	private let url: URL
	private let client: HTTPClient
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public func load(completion: @escaping (CommentLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200 && !data.isEmpty else {
					return completion(.failure(Error.invalidData))
				}
				
				guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
					return completion(.failure(Error.invalidData))
				}
				completion(.success(root.items))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

//
//  RemoteCommentLoader.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteCommentLoader {
	
	private let url: URL
	private let client: HTTPClient
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public typealias Result = Swift.Result<[Comment], Error>
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200 && !data.isEmpty else {
					return completion(.failure(.invalidData))
				}
				
				guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
					return completion(.failure(.invalidData))
				}
				completion(.success(root.items))
			case .failure:
				completion(.failure(.connectivity))
			}
		}
	}
}

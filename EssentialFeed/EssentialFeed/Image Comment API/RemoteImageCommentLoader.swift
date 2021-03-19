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

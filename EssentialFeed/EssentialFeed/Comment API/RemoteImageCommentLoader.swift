//
//  RemoteImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 3/16/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentLoader {
	private let httpClient: HTTPClient
	private let url: URL
	
	public typealias Result = Swift.Result<[ImageComment], Error>
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.httpClient = client
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		httpClient.get(from: url) { [weak self] (result) in
			guard self != nil else { return }
			
			switch result {
			case .failure:
				completion(.failure(.connectivity))
				
			case let .success((data, response)):
				completion(RemoteImageCommentLoader.map(data, response: response))
			}
		}
	}
	
	static func map(_ data: Data, response: HTTPURLResponse) -> Result {
		do {
			let remoteComments = try ImageCommentMapper.map(data, from: response)
			let comments = remoteComments.map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: ImageCommentAuthor(username: $0.author.username))
			}
			
			return .success(comments)
		} catch {
			return .failure(RemoteImageCommentLoader.Error.invalidData)
		}
	}
}

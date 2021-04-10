//
//  RemoteImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Antonio Mayorga on 3/16/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentLoader: ImageCommentLoader {
	private let httpClient: HTTPClient
	private let url: URL
	
	public typealias Result = Swift.Result<[ImageComment], RemoteImageCommentLoader.Error>
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.httpClient = client
	}
	
	private final class HTTPClientTaskWrapper: ImageCommentLoaderTask {
		private var completion: ((ImageCommentLoader.LoadImageCommentResult) -> Void)?
		
		var wrapped: HTTPClientTask?
		
		init(_ completion: @escaping (ImageCommentLoader.LoadImageCommentResult) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: ImageCommentLoader.LoadImageCommentResult) {
			completion?(result)
		}
		
		func cancel() {
			preventFurtherCompletions()
			wrapped?.cancel()
		}
		
		private func preventFurtherCompletions() {
			completion = nil
		}
	}
	
	public func load(completion: @escaping (LoadImageCommentResult) -> Void) -> ImageCommentLoaderTask {
		let task = HTTPClientTaskWrapper(completion)
		task.wrapped = httpClient.get(from: url) { [weak self] (result) in
			guard self != nil else { return }
			
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
				
			case let .success((data, response)):
				completion(RemoteImageCommentLoader.map(data, response: response))
			}
		}
		
		return task
	}
	
	static func map(_ data: Data, response: HTTPURLResponse) -> LoadImageCommentResult {
		do {
			let remoteComments = try ImageCommentMapper.map(data, from: response)
			let comments = remoteComments.map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: ImageCommentAuthor(username: $0.author.username))
			}
			
			return .success(comments)
		} catch {
			return .failure(Error.invalidData)
		}
	}
}

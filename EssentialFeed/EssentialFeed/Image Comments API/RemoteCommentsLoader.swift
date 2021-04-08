//
//  RemoteCommentsLoader.swift
//  EssentialFeed
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteCommentsLoader: ImageCommentsLoader {
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = ImageCommentsLoader.Result
	
	private let url: URL
	private let client: HTTPClient
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Result) -> Void) -> ImageCommentsLoaderTask {
		let task = HTTPClientTaskWrapper(completion: completion)
		task.wrappedTask = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			
			switch result {
			case .failure:
				task.complete(with: .failure(Error.connectivity))
				
			case let .success((data, response)):
				task.complete(with: RemoteCommentsLoader.map(data, from: response))
			}
		}
		return task
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let imageComments = try ImageCommentsMapper.map(data, from: response)
			return .success(imageComments.toModels())
		} catch {
			return .failure(error)
		}
	}
}

private final class HTTPClientTaskWrapper: ImageCommentsLoaderTask {
	typealias Result = RemoteCommentsLoader.Result
	
	private var completion: ((Result) -> Void)?
	var wrappedTask: HTTPClientTask?
	
	init(completion: @escaping (Result) -> Void) {
		self.completion = completion
	}
	
	func complete(with result: Result) {
		completion?(result)
	}
	
	func cancel() {
		wrappedTask?.cancel()
		preventFurtherCompletions()
	}
	
	private func preventFurtherCompletions() {
		completion = nil
	}
}

private extension Array where Element == RemoteImageComment {
	func toModels() -> [ImageComment] {
		return map {
			ImageComment(
				id: $0.id,
				message: $0.message,
				createdAt: $0.created_at,
				author: ImageCommentAuthor(username: $0.author.username))
		}
	}
}

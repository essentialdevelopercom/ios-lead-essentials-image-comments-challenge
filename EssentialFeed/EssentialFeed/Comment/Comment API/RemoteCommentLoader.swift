//
//  RemoteCommentLoader.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

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
	
	private final class CommentTaskWrapper: CommentLoaderTask {
		private var completion: ((CommentLoader.Result) -> Void)?
		var wrapped: HTTPClientTask?
		
		init(completion: @escaping (CommentLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func cancel() {
			wrapped?.cancel()
			preventFurtherCompletion()
		}
		
		func completeWith(result: CommentLoader.Result) {
			completion?(result)
		}
		
		private func preventFurtherCompletion() {
			completion = nil
		}
	}
	
	public func load(completion: @escaping (CommentLoader.Result) -> Void) -> CommentLoaderTask {
		let task = CommentTaskWrapper(completion: completion)
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			
			task.completeWith(result: result
								.mapError { _ in Error.connectivity}
								.flatMap { (data, response) in
									RemoteCommentLoader.map(data, response)
								}
			)
		}
		
		return task
	}
	
	private static func map(_ data: Data, _ response: HTTPURLResponse) -> CommentLoader.Result {
		guard let comments = try? CommentItemMapper.map(data, response) else {
			return .failure(Error.invalidData)
		}
		
		return .success(comments.toModels())
	}
}

private extension Array where Element == RemoteComment {
	func toModels() -> [Comment] {
		return self.map {
			Comment(id: $0.id, message: $0.message, createAt: $0.createAt, author: $0.author.toModel())
		}
	}
}

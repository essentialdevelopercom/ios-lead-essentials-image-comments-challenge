//
//  RemoteCommentLoader.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentLoader: ImageCommentLoader {
	
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error, Equatable {
		case connectivity
		case invalidData
	}
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	private final class HTTPClientTaskWrapper: ImageCommentLoaderDataTask {
		private var completion: ((ImageCommentLoader.Result) -> Void)?
		
		var wrapped: HTTPClientTask?
		
		init(_ completion: @escaping (ImageCommentLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: ImageCommentLoader.Result) {
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
	
	@discardableResult
	public func load(completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderDataTask {
		let task = HTTPClientTaskWrapper(completion)
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			
			switch result {
			case let .success((data, response)):
				completion(RemoteImageCommentLoader.map(data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
		return task
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> ImageCommentLoader.Result {
		do {
			let items = try ImageCommentMapper.map(data, from: response)
			return .success(items.toLocal())
		} catch {
			return .failure(error)
		}
	}
	
}

private extension Array where Element == RemoteImageComment {
	func toLocal() -> [ImageComment] {
		return map { $0.local }
	}
}

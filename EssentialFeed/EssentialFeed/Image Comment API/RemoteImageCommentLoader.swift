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
	
	private final class HTTPTaskWrapper: ImageCommentLoaderTask {
		var wrapped: HTTPClientTask?
		
		func cancel() {
			wrapped?.cancel()
		}
	}
	
	private let client: HTTPClient
	
	public init(client: HTTPClient) {
		self.client = client
	}
	
	public func load(from url: URL, completion: @escaping (Result) -> Void) -> ImageCommentLoaderTask {
		let task = HTTPTaskWrapper()
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			completion(result
				.mapError { _ in Error.connectivity }
				.flatMap { (data, response) in
					RemoteImageCommentLoader.map(data, from: response)
				}
			)
		}
		return task
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let comments = try ImageCommentMapper.map(data, from: response)
			return .success(comments)
		} catch {
			return .failure(error)
		}
	}
}

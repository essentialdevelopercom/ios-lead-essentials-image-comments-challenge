//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 03/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentsLoader: ImageCommentsLoader {
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(client: HTTPClient) {
		self.client = client
	}
	
	private final class HTTPClientTaskWrapper: ImageCommmentsLoaderTask {
		private var completion: ((ImageCommentsLoader.Result) -> Void)?
		
		var wrapped: HTTPClientTask?
		
		init(_ completion: @escaping (ImageCommentsLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: FeedImageDataLoader.Result) {
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
	
	public func loadImageComments(from url: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommmentsLoaderTask {
		let task = HTTPClientTaskWrapper(completion)
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			
			task.complete(with: result
				.mapError { _ in Error.connectivity}
				.flatMap { data, response in
					let isValidResponse = response.isOK && !data.isEmpty
					return isValidResponse ? .success(data) : .failure(Error.invalidData)
				})
		}
		return task
	}
}

//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Alok Subedi on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentsLoader: ImageCommentsLoader {
	private let client: HTTPClient
	private let url: URL
	
	public init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	private final class HTTPClientTaskWrapper: ImageCommentsLoaderTask {
		private var completion: ((ImageCommentsLoader.Result) -> Void)?
		
		var wrapped: HTTPClientTask?
		
		init(_ completion: @escaping (ImageCommentsLoader.Result) -> Void) {
			self.completion = completion
		}
		
		func complete(with result: ImageCommentsLoader.Result) {
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
	
	public func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
		let task = HTTPClientTaskWrapper(completion)
		task.wrapped = client.get(from: url){ [weak self] result in
			guard self != nil else { return }
			
			task.complete(with: result
							.mapError { _ in Error.connectivity }
							.flatMap { (data, response) in
								Result {
									try ImageCommentsMapper.map(data: data, from: response)
								}
							}
			)
		}
		return task
	}
}

//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 09/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteImageCommentsLoader: ImageCommentsLoader {

	public typealias Result = ImageCommentsLoader.Result

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	private final class HTTPClientTaskWrapper: HTTPClientTask {
		private var completion: ((Result) -> Void)?
		var wrapped: HTTPClientTask?

		init(completion: @escaping (Result) -> Void) {
			self.completion = completion
		}

		func cancel() {
			wrapped?.cancel()
			preventFurtherCompletions()
		}

		func complete(with result: Result) {
			completion?(result)
		}

		private func preventFurtherCompletions() {
			completion = nil
		}
	}

	private let client: HTTPClient

	public init(client: HTTPClient) {
		self.client = client
	}

	@discardableResult
	public func load(
		from url: URL,
		completion: @escaping (Result) -> Void
	) -> HTTPClientTask {
		let task = HTTPClientTaskWrapper(completion: completion)
		task.wrapped = client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				task.complete(with: RemoteImageCommentsLoader.map(data, from: response))

			case .failure:
				task.complete(with: .failure(RemoteImageCommentsLoader.Error.connectivity))
			}
		}

		return task
	}

	private static func map(
		_ data: Data,
		from response: HTTPURLResponse
	) -> Result {
		do {
			let items = try ImageCommentsMapper.map(data, from: response)
			return .success(items)
		} catch {
			return .failure(error)
		}
	}
}

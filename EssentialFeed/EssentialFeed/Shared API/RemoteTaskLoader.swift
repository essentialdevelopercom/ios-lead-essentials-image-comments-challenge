//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public protocol LoaderTask {
	func cancel()
}

public final class RemoteTaskLoader<Resource> {
	private let client: HTTPClient
	private let mapper: Mapper

	public init(client: HTTPClient, mapper: @escaping Mapper) {
		self.client = client
		self.mapper = mapper
	}

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public typealias Result = Swift.Result<Resource, Error>
	public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource

	private final class HTTPClientTaskWrapper: LoaderTask {
		private var completion: ((Result) -> Void)?

		var wrapped: HTTPClientTask?

		init(_ completion: @escaping (Result) -> Void) {
			self.completion = completion
		}

		func complete(with result: Result) {
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

	public func load(from url: URL, completion: @escaping (Result) -> Void) -> LoaderTask {
		let task = HTTPClientTaskWrapper(completion)
		task.wrapped = client.get(from: url) { [weak self] result in
			guard let self = self else { return }

			task.complete(with: result
				.mapError { _ in Error.connectivity }
				.flatMap { self.map($0, from: $1) })
		}
		return task
	}

	private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			return .success(try mapper(data, response))
		} catch {
			return .failure(Error.invalidData)
		}
	}
}

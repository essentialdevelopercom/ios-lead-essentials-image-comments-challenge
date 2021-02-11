//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 10/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteLoader<Resource> {

	public typealias Result = Swift.Result<Resource, Swift.Error>
	public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource

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

	private let url: URL
	private let client: HTTPClient
	private let mapper: Mapper

	public init(
		url: URL,
		client: HTTPClient,
		mapper: @escaping Mapper
	) {
		self.url = url
		self.client = client
		self.mapper = mapper
	}

	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case let .success((data, response)):
				completion(self.map(data, from: response))

			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private func map(
		_ data: Data,
		from response: HTTPURLResponse
	) -> Result {
		do {
			return .success(try mapper(data, response))
		} catch {
			return .failure(Error.invalidData)
		}
	}
}

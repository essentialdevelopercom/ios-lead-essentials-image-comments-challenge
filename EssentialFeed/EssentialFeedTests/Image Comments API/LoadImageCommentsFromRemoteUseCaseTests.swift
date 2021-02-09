//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 08/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

public final class RemoteImageCommentsLoader {

	public typealias Result = Swift.Result<Any, Error>

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	private let client: HTTPClient

	public init(client: HTTPClient) {
		self.client = client
	}

	public func load(
		from url: URL,
		completion: @escaping (Result) -> Void
	) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				guard response.isOK,
					  let _ = try? JSONSerialization.jsonObject(with: data)
				else {
					return completion(.failure(.invalidData))
				}
			case .failure:
				completion(.failure(.connectivity))
			}

		}
	}
}

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load(from: url) { _ in }

		XCTAssertEqual(client.requestedURLs, [url])
	}

	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load(from: url) { _ in }
		sut.load(from: url) { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}

	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		let expectedError = RemoteImageCommentsLoader.Error.connectivity

		expect(
			sut: sut,
			toCompleteWith: .failure(expectedError),
			when: {
				client.complete(with: expectedError)
			}
		)
	}

	func test_load_deliversErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()

		let samples = [199, 300, 400, 401, 500]

		samples.enumerated().forEach { index, code in
			expect(
				sut: sut,
				toCompleteWith: .failure(.invalidData),
				when: {
					client.complete(
						withStatusCode: code,
						data: anyData(),
						at: index
					)
				}
			)
		}
	}

	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()

		expect(
			sut: sut,
			toCompleteWith: .failure(.invalidData),
			when: {
				let invalidJSON = Data("invalid json".utf8)
				client.complete(
					withStatusCode: 200,
					data: invalidJSON
				)
			}
		)
	}

	// MARK: - Helpers

	private func makeSUT(
		url: URL = anyURL(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}

	private func expect(
		sut: RemoteImageCommentsLoader,
		toCompleteWith expectedResult: RemoteImageCommentsLoader.Result,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let exp = expectation(description: "Wait completion loader")
		let url = URL(string: "https://a-given-url.com")!

		sut.load(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.failure(receivedError), .failure(expectedError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			default:
				XCTFail("Expected failure, but got \(receivedResult) instead.")
			}

			exp.fulfill()
		}

		action()

		wait(for: [exp], timeout: 1.0)
	}
}

extension HTTPURLResponse {
	var isOK: Bool {
		(200...299).contains(statusCode)
	}
 }

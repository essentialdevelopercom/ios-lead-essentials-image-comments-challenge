//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Rakesh Ramamurthy on 01/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct ImageComment {
	let id: UUID
	let message: String
	let createdAt: Date
	let author: String
}

class RemoteImageCommentsLoader {
	let client: HTTPClient
	typealias Result = Swift.Result<[ImageComment], Swift.Error>

	enum Error: Swift.Error {
		case invalidData
	}

	private static var OK_HTTP_200: Int { return 200 }

	init(client: HTTPClient) {
		self.client = client
	}

	func load(from url: URL, completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((_, response)):
				if response.statusCode != RemoteImageCommentsLoader.OK_HTTP_200 {
					completion(.failure(Error.invalidData))
				}
			case let .failure(error):
				completion(.failure(error))
			}
		}
	}
}

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
	
	func test_init_doesNotPerformAnyURLRequest() {
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
		let url = URL(string: "https://a-given-url.com")!
		let expectedError = anyNSError()

		let exp = expectation(description: "Wait completion loader")
		sut.load(from: url) { result in
			switch result {
			case let .failure(receivedError):
				XCTAssertEqual(receivedError as NSError?, expectedError as NSError?)
			default:
				XCTFail("Expected failure, git \(result) instead.")
			}
			exp.fulfill()
		}

		client.complete(with: expectedError)
		wait(for: [exp], timeout: 1.0)
	}

	func test_load_deliversErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()
		let url = URL(string: "https://a-given-url.com")!
		let expectedError = RemoteImageCommentsLoader.Error.invalidData
		let samples = [199, 300, 345, 400, 500]

		samples.enumerated().forEach { index, code in
			let exp = expectation(description: "Wait completion loader")
			sut.load(from: url) { result in
				switch result {
				case let .failure(receivedError):
					XCTAssertEqual(receivedError as NSError?, expectedError as NSError?)
				default:
					XCTFail("Expected failure, git \(result) instead.")
				}
				exp.fulfill()
			}

			client.complete(withStatusCode: code, data: anyData(), at: index)
			wait(for: [exp], timeout: 1.0)
		}
	}

	// MARK: - Helpers
	
	private func makeSUT(
		url _: URL = anyURL(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
}

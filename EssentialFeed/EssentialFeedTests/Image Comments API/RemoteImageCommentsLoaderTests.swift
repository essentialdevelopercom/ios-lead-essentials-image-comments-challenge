//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Cronay on 13.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteImageCommentsLoader {
	private let client: HTTPClient
	private let url: URL

	init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}

	func load(completion: @escaping (Error?) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .failure(error):
				completion(error)

			default: break
			}
		}
	}
}

class RemoteImageCommentsLoaderTests: XCTestCase {

	func test_init_doesNotRequestFromURL() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsFromURL() {
		let commentsURL = URL(string: "http://comments-url.com")!
		let (sut, client) = makeSUT(url: commentsURL)

		sut.load() { _ in }

		XCTAssertEqual(client.requestedURLs, [commentsURL])
	}

	func test_loadTwice_requestsFromURLTwice() {
		let commentsURL = URL(string: "http://comments-url.com")!
		let (sut, client) = makeSUT(url: commentsURL)

		sut.load() { _ in }
		sut.load() { _ in }

		XCTAssertEqual(client.requestedURLs, [commentsURL, commentsURL])
	}

	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		let exp = expectation(description: "Wait for load completion")

		var receivedError: Error?
		sut.load { error in
			receivedError = error
			exp.fulfill()
		}

		client.complete(with: anyNSError())

		wait(for: [exp], timeout: 1.0)

		XCTAssertNotNil(receivedError)
	}

	// MARK: - Helpers

	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client, url: url)
		trackForMemoryLeaks(client)
		trackForMemoryLeaks(sut)
		return (sut, client)
	}
}

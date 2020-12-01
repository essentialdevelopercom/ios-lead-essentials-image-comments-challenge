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

	init(client: HTTPClient) {
		self.client = client
	}

	func load(from url: URL, completion: @escaping (Result<[ImageComment], Error>) -> Void) {
		client.get(from: url) { _ in
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

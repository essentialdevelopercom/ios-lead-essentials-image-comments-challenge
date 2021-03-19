//
//  RemoteImageCommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 17/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class RemoteImageCommentLoader {
	
	let client: HTTPClient
	
	init(client: HTTPClient) {
		self.client = client
	}
	
	func load(from url: URL) {
		client.get(from: url) { _ in }
	}
}

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let (sut, client) = makeSUT()
		let url = anyURL()
		
		sut.load(from: url)
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentLoader(client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
}

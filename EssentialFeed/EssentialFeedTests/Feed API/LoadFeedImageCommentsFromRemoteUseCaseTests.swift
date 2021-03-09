//
//  LoadFeedImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ivan Ornes on 9/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedImageCommentsFromRemoteUseCaseTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_loadImageCommentsFromURL_requestsCommentsFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		_ = sut.loadImageComments(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadImageCommentsFromURLTwice_requestsCommentsFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		_ = sut.loadImageComments(from: url) { _ in }
		_ = sut.loadImageComments(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageCommentsLoader(url: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
}

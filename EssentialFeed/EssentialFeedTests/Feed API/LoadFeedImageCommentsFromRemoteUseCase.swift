//
//  LoadFeedImageCommentsFromRemoteUseCase.swift
//  EssentialFeedTests
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedImageCommentsLoader {
	let client: HTTPClient
	let url: URL
	
	init(client: HTTPClient, url: URL = URL(string: "https://a-url.com")!) {
		self.client = client
		self.url = url
	}
	
	func load() {
		client.get(from: url, completion: { _ in })
	}
}

class LoadFeedImageCommentsFromRemoteUseCase: XCTestCase {
	
	func test_init_doesNotRequestsDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "http://a-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	// MARK - Helpers
	
	func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedImageCommentsLoader, HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageCommentsLoader(client: client, url: url)
		return (sut, client)
	}
}

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
		let client = HTTPClientSpy()
		let _ = RemoteFeedImageCommentsLoader(client: client)
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let client = HTTPClientSpy()
		let url = URL(string: "http://a-url.com")!
		let sut = RemoteFeedImageCommentsLoader(client: client, url: url)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
}

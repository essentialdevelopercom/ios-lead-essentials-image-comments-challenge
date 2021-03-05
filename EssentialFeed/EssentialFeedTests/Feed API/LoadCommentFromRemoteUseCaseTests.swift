//
//  LoadCommentFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Mayorga on 3/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import Foundation
import EssentialFeed

class RemoteCommentLoader {
	let url: URL
	let httpClient: HTTPClient
	
	init(url: URL, client: HTTPClient) {
		self.url = url
		self.httpClient = client
	}
	
	func load() {
		httpClient.get(from: url) { (result) in
			print(result)
		}
	}
}

class LoadCommentFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotRequestDataOnInit() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestDataFromURL() {
		let url = URL(string: "https://another-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestDataFromURLTwice() {
		let url = URL(string: "https://another-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
}

// MARK: - Helpers
private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteCommentLoader, spy: HTTPClientSpy) {
	let client = HTTPClientSpy()
	let sut = RemoteCommentLoader(url: url, client: client)
	
	return (sut, client)
}

//
//  LoadCommentsFromRemoteUseCasesTests.swift
//  EssentialFeediOSTests
//
//  Created by Robert Dates on 1/19/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedCommentsLoader {
	
	private let url: URL
	private let client: HTTPClient
	
	init(client: HTTPClient, url: URL) {
		self.url = url
		self.client = client
	}
	
	func load() {
		client.get(from: url) { _ in
			
		}
	}
}


class LoadCommentsFromRemoteUseCasesTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load()
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedCommentsLoader, client: HTTPClientSpy) {
		let client =  HTTPClientSpy()
		let sut = RemoteFeedCommentsLoader(client: client, url: url)
		trackForMemoryLeaks(client)
		trackForMemoryLeaks(sut)
		
		return (sut, client)
	}

}

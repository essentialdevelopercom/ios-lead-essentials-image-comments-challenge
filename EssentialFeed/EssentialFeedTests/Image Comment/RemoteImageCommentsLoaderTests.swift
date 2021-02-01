//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 01/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

class RemoteImageCommentsLoader {
	private let client: HTTPImageClient
	
	init(client: HTTPImageClient) {
		self.client = client
	}
	
	func load() {
		client.get()
	}
}

class HTTPImageClient {
	var requestCallCount = 0
	
	func get() {
		requestCallCount += 1
	}
}

class RemoteImageCommentsLoaderTests: XCTestCase {
	func test_init_doesNotRequestDataFromUrl() {
		let client = HTTPImageClient()
		let _ = RemoteImageCommentsLoader(client: client)
		
		XCTAssertEqual(client.requestCallCount, 0)
	}
	
	func test_everyTimeloadIsCalled_requestsDataFromUrl() {
		let client = HTTPImageClient()
		let sut = RemoteImageCommentsLoader(client: client)
		
		sut.load()
		XCTAssertEqual(client.requestCallCount, 1)
		
		sut.load()
		sut.load()
		XCTAssertEqual(client.requestCallCount, 3)
	}
}

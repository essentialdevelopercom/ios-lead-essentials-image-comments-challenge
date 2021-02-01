//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 01/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

class RemoteImageCommentsLoader {
	init(client: HTTPImageClient) {
		
	}
}

class HTTPImageClient {
	var requestCallCount = 0
}

class RemoteImageCommentsLoaderTests: XCTestCase {
	func test_init_doesNotRequestDataFromUrl() {
		let client = HTTPImageClient()
		let _ = RemoteImageCommentsLoader(client: client)
		
		XCTAssertEqual(client.requestCallCount, 0)
	}
}

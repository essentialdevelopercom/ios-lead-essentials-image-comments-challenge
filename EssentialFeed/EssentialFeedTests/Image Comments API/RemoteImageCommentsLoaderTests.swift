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
	init(client: HTTPClient) {

	}
}

class RemoteImageCommentsLoaderTests: XCTestCase {

	func test_init_doesNotRequestFromURL() {
		let client = HTTPClientSpy()
		_ = RemoteImageCommentsLoader(client: client)

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
}

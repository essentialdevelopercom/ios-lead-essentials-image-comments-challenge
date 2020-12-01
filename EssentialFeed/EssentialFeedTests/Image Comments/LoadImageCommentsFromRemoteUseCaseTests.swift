//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Rakesh Ramamurthy on 01/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteImageCommentsLoader {
	init(client _: HTTPClient) {}
}

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotPerformAnyURLRequest() {
		let client = HTTPClientSpy()
		let _ = RemoteImageCommentsLoader(client: client)

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
}

//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Mayorga on 4/25/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedEndpointTests: XCTestCase {

	func test_feed_endpointURL() {
		let baseURL = URL(string: "http://base-url.com")!

		let received = FeedEndpoint.get.url(baseURL: baseURL)
		let expected = URL(string: "http://base-url.com/v1/feed")!

		XCTAssertEqual(received, expected)
	}
}

//
//  EssentialFeedEndpoint.swift
//  EssentialAppTests
//
//  Created by Cronay on 27.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialApp

class EssentialFeedEndpointTests: XCTestCase {

	func test_feedEndpoint_isReturnedCorrectly() {
		let expectedURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

		XCTAssertEqual(expectedURL, EssentialFeedEndpoint.feed.url)
	}
}

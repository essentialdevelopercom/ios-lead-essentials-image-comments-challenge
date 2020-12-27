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

	func test_imageCommentEndpoint_isReturnedCorrectly() {
		let id = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
		let expectedURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/E621E1F8-C36C-495A-93FC-0C247A3E6E5F/comments")!

		XCTAssertEqual(expectedURL, EssentialFeedEndpoint.comments(id: id).url)
	}
}

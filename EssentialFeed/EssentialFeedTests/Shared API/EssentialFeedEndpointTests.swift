//
//  EssentialFeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 20/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class EssentialFeedEndpointTests: XCTestCase {

	func test_feedEndpontURL_isCorrect() {
		let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
		let endpoint = EssentialFeedEndpoint.feed.url(baseURL: baseURL)

		let expected = URL(
			string: "\(baseURL)/v1/feed"
		)!
		XCTAssertEqual(
			endpoint,
			expected,
			"Expected URL \(expected.absoluteString) but got \(endpoint.absoluteString) instead"
		)
	}

	func test_imageCommentsEndpontURL_isCorrect() {
		let uuidString = "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086"
		let imageID = UUID(uuidString: uuidString)!
		let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
		let endpoint = EssentialFeedEndpoint.imageComments(id: imageID).url(baseURL: baseURL)

		let expected = URL(
			string: "\(baseURL)/v1/image/\(uuidString)/comments"
		)!
		XCTAssertEqual(
			endpoint,
			expected,
			"Expected URL \(expected.absoluteString) but got \(endpoint.absoluteString) instead"
		)
	}
}

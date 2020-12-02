//
//  ImageCommentsAPIEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Rakesh Ramamurthy on 02/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class EssentialFeedEndpointTests: XCTestCase {
	func test_feedEndpoint_isCorrectURL() {
		let baseUrl = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
		let endpoint = EssentialFeedEndpoint.feed.url(baseUrl)

		let expected = URL(
			string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed"
		)!
		XCTAssertEqual(endpoint, expected, "Expected \(expected.absoluteString) URL, but got \(endpoint.absoluteString) instead")
	}

	func test_imageCommentsEndpont_isCorrectURL() {
		let baseUrl = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
		let imageId = UUID(uuidString: "5BCC6F46-1A48-11EB-ADC1-0242AC120002")!
		let endpoint = EssentialFeedEndpoint.comments(for: imageId).url(baseUrl)

		let expected = URL(
			string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/5BCC6F46-1A48-11EB-ADC1-0242AC120002/comments"
		)!
		XCTAssertEqual(endpoint, expected, "Expected \(expected.absoluteString) URL, but got \(endpoint.absoluteString) instead")
	}
}

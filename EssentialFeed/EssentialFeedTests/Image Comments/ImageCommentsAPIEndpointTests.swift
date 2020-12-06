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
	func test_imageCommentsEndpont_isCorrectURL() {
		let imageId = "5bcc6f46-1a48-11eb-adc1-0242ac120002"
		let endpoint = EssentialFeedEndpoint.comments(for: imageId).url()

		let expected =
			URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/5bcc6f46-1a48-11eb-adc1-0242ac120002/comments")!
		XCTAssertEqual(endpoint, expected, "Expected \(expected.absoluteString) URL, but got \(endpoint.absoluteString) instead")
	}
}

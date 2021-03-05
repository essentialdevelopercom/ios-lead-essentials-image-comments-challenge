//
//  EssentialFeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Robert Dates on 3/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class EssentialFeedEndpointTests: XCTestCase {
	
	func test_essentialFeedEndpoint_feedUseCase() {
		let url: URL = URL(string: "url.com")!
		let feed = EssentialFeedEndpoint.feed
		
		let resultURL = feed.url(baseURL: url)
		
		XCTAssertEqual(url.appendingPathComponent("v1/feed").absoluteString, resultURL.absoluteString)
		XCTAssertEqual(url.baseURL, resultURL.baseURL)
	}
	
	func test_essentialFeedEndpoint_commentsUseCase() {
		let url: URL = URL(string: "url.com")!
		let id = UUID()
		let comment = EssentialFeedEndpoint.comments(id: id)
		
		let resultURL = comment.url(baseURL: url)
		
		XCTAssertEqual(url.appendingPathComponent("v1/image/\(id)/comments").absoluteString, resultURL.absoluteString)
		XCTAssertEqual(url.baseURL, resultURL.baseURL)
	}
}

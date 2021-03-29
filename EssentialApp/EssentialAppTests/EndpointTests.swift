//
//  EndpointTests.swift
//  EssentialAppTests
//
//  Created by Ángel Vázquez on 28/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

enum Endpoint {
	case feed
	
	static var baseURL: URL {
		URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/")!
	}
	
	static func url(for endpoint: Endpoint) -> URL {
		switch endpoint {
		case .feed:
			return baseURL.appendingPathComponent("v1/feed")
		}
	}
}

class EndpointTests: XCTestCase {
	func test_feedURL_returnsCorrectURL() {
		let feedURL = Endpoint.url(for: .feed)
		
		XCTAssertEqual(feedURL.absoluteString, "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")
	}
}

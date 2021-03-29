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
	case imageComments(id: String)
	
	static var baseURL: URL {
		URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/")!
	}
	
	static func url(for endpoint: Endpoint) -> URL {
		switch endpoint {
		case .feed:
			return baseURL.appendingPathComponent("v1/feed")
		case let .imageComments(id: id):
			return baseURL.appendingPathComponent("v1/image/\(id)/comments")
		}
	}
}

class EndpointTests: XCTestCase {
	func test_feedURL_returnsCorrectURL() {
		let feedURL = Endpoint.url(for: .feed)
		
		XCTAssertEqual(feedURL.absoluteString, "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")
	}
	
	func test_imageCommentsURL_returnsCorrectURL() {
		let imageID = UUID().uuidString
		let imageCommentsURL = Endpoint.url(for: .imageComments(id: imageID))
		
		XCTAssertEqual(imageCommentsURL.absoluteString, "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(imageID)/comments")
	}
}

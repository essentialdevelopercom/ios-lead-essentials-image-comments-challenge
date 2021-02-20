//
//  EssentialFeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 20/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

enum EssentialFeedEndpoint {
	case imageComments(id: UUID)

	var url: URL {
		let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

		switch self {

		case .imageComments(let id):
			return baseURL.appendingPathComponent("v1/image/\(id)/comments")
		}
	}
}

class EssentialFeedEndpointTests: XCTestCase {

	func test_imageCommentsEndpontURL_isCorrect() {
		let uuidString = "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086"
		let imageID = UUID(uuidString: uuidString)!
		let endpoint = EssentialFeedEndpoint.imageComments(id: imageID).url

		let expected = URL(
			string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(uuidString)/comments"
		)!
		XCTAssertEqual(
			endpoint,
			expected,
			"Expected URL \(expected.absoluteString) but got \(endpoint.absoluteString) instead"
		)
	}
}

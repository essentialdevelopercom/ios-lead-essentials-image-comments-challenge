//
//  APIEndpointTests.swift
//  EssentialAppTests
//
//  Created by Danil Vassyakin on 5/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialApp

class APIEndpointTests: XCTestCase {

	func test_feedUrl_isCorrect() {
		let expectedURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

		XCTAssertEqual(expectedURL, APIEndpoint.feed.url)
	}

	func test_imageCommentUrlWithImageId_isCorrect() {
		let id = UUID(uuidString: "11E123D5-1272-4F17-9B91-F3D0FFEC895A")!
		let expectedURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/11E123D5-1272-4F17-9B91-F3D0FFEC895A/comments")!

		XCTAssertEqual(expectedURL, APIEndpoint.comments(imageId: id).url)
	}
}

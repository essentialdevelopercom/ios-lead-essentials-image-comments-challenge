//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Mario Alberto Barragán Espinosa on 07/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {
	
	func test_endToEndTestServerGETFeedCommentsResult_matchesFixedTestAccountData() {
		switch getFeedCommentResult() {
		case let .success(imageCommentFeed)?:
			XCTAssertEqual(imageCommentFeed.count, 3, "Expected 3 images in the test account image comment feed")
			
		case let .failure(error)?:
			XCTFail("Expected succesful feed result, got \(error) instead")
			
		default:
			XCTFail("Expected succesful feed result, got no result instead")
		}
	}
	
	// MARK: - Helpers
	
	private func getFeedCommentResult(file: StaticString = #file, line: UInt = #line) -> FeedImageCommentLoader.Result? {
		let loader = RemoteFeedImageCommentLoader(client: ephemeralClient())
		trackForMemoryLeaks(loader, file: file, line: line)

		let exp = expectation(description: "Wait for load completion")
		
		let url = feedTestServerURL.appendingPathComponent("11E123D5-1272-4F17-9B91-F3D0FFEC895A/comments")

		var receivedResult: FeedImageCommentLoader.Result?
		loader.loadImageCommentData(from: url) { result in
			receivedResult = result
			exp.fulfill()
		}
		wait(for: [exp], timeout: 5.0)

		return receivedResult
	}
	
	private var feedTestServerURL: URL {
		return URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image")!
	}
	
	private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
		let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
		trackForMemoryLeaks(client, file: file, line: line)
		return client
	}
}

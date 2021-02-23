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
			XCTAssertEqual(imageCommentFeed[0], expectedComment(at: 0))
			XCTAssertEqual(imageCommentFeed[1], expectedComment(at: 1))
			XCTAssertEqual(imageCommentFeed[2], expectedComment(at: 2))
			
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
		
		let url = feedTestServerURL.appendingPathComponent("54F35D06-9CC6-4294-A0D8-963D397E8B98/comments")

		var receivedResult: FeedImageCommentLoader.Result?
		loader.loadImageCommentData(from: url) { result in
			receivedResult = result
			exp.fulfill()
		}
		wait(for: [exp], timeout: 5.0)

		return receivedResult
	}
	
	private var feedTestServerURL: URL {
		return URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/image")!
	}
	
	private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
		let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
		trackForMemoryLeaks(client, file: file, line: line)
		return client
	}
	
	private func expectedComment(at index: Int) -> FeedImageComment {
		return FeedImageComment(id: id(at: index), 
								message: message(at: index), 
								creationDate: creationDate(at: index).toISO8601Date(), 
								authorUsername: authorUsername(at: index))
	}
	
	private func id(at index: Int) -> UUID {
		return UUID(uuidString: [
			"7019D8A7-0B35-4057-B7F9-8C5471961ED0",
			"1F4A3B22-9E6E-46FC-BB6C-48B33269951B",
			"00D0CD9A-452C-4812-B264-1B73823C94CA",
		][index])!
	}
	
	private func message(at index: Int) -> String {
		return [
			"message-1",
			"message-2",
			"message-3",
		][index]
	}
	
	private func creationDate(at index: Int) -> String {
		return [
			"2020-07-31T11:24:59+0000",
			"2020-07-31T04:23:53+0000",
			"2020-07-26T11:22:59+0000",
		][index]
	}
	
	private func authorUsername(at index: Int) -> String {
		return [
			"username-1",
			"username-2",
			"username-3",
		][index]
	}
}

private extension String {
	func toISO8601Date()-> Date {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter.date(from:self)!
	}
}

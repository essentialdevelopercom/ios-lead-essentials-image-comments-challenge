//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedTests
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CommentAPIEndToEndTests: XCTestCase {
	func test_endToEndTestServerGETComment_matchesFixedTestAccountData() {
		switch getCommentResult() {
		case let .success(comments):
			XCTAssertEqual(comments.count, 3)
			XCTAssertEqual(comments[0], expectedComment(at: 0))
			XCTAssertEqual(comments[1], expectedComment(at: 1))
			XCTAssertEqual(comments[2], expectedComment(at: 2))
			
		case let .failure(error):
			XCTFail("Expected to successfully get comment data, got\(error)")
		default:
			XCTFail()
		}
	}
	
	// MARK: - Helpers
	private func getCommentResult(file: StaticString = #file, line: UInt = #line) -> CommentLoader.Result? {
		let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
		let loader = RemoteCommentLoader(url: commentTestServerURL, client: client)
		
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		
		let exp = expectation(description: "Wait for load completion")
		var receivedResult: CommentLoader.Result?
		loader.load { result in
			receivedResult = result
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 5.0)
		return receivedResult
	}
	
	private var commentTestServerURL: URL {
		return URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/11E123D5-1272-4F17-9B91-F3D0FFEC895A/comments")!
	}
	
	private func id(at index: Int) -> UUID {
		return UUID(uuidString: [
			"7019D8A7-0B35-4057-B7F9-8C5471961ED0",
			"1F4A3B22-9E6E-46FC-BB6C-48B33269951B",
			"00D0CD9A-452C-4812-B264-1B73823C94CA"
		][index])!
	}
	
	private func message(at index: Int) -> String {
		return [
			"The gallery was seen in Wolfgang Becker's movie Goodbye, Lenin!",
			"It was also featured in English indie/rock band Bloc Party's single Kreuzberg taken from the album A Weekend in the City.",
			"The restoration process has been marked by major conflict. Eight of the artists of 1990 refused to paint their own images again after they were completely destroyed by the renovation. In order to defend the copyright, they founded Founder Initiative East Side with other artists whose images were copied without permission."
		][index]
	}
	
	private func createdAt(at index: Int) -> Date {
		return ISO8601DateFormatter().date(from: [
			"2020-10-09T11:24:59+0000",
			"2020-10-01T04:23:53+0000",
			"2020-09-26T11:22:59+0000",
		][index])!
	}
	
	private func author(at index: Int) -> CommentAuthor {
		return [
			CommentAuthor(username: "Joe"),
			CommentAuthor(username: "Megan"),
			CommentAuthor(username: "Dwight")
		][index]
	}
	
	private func expectedComment(at index: Int) -> Comment {
		return Comment(
			id: id(at: index),
			message: message(at: index),
			createAt: createdAt(at: index),
			author: author(at: index))
	}
}

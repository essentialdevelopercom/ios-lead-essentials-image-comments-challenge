//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Ángel Vázquez on 19/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class EssentialFeedAPIEndToEndTests: XCTestCase {
	func test_endToEndTestServerGETImageCommentsResult_matchesFixedTestCommentsData() {
		let loader = makeRemoteImageCommentLoader()
		
		let exp = expectation(description: "Wait for load completion")
		let url = URL(string: "https://gist.githubusercontent.com/Angel5215/0a68e5ad1057231a825d70e6b233ac67/raw/dec7ca63f69708ab7735deaa21cbc6283e45cf16/test-comments-list.json")!
		
		_ = loader.load(from: url) { [unowned self] result in
			switch result {
			case let .success(comments):
				XCTAssertEqual(comments.count, 3, "Expected 3 comments in test comments list result")
				XCTAssertEqual(comments[0], self.expectedComment(at: 0))
				XCTAssertEqual(comments[1], self.expectedComment(at: 1))
				XCTAssertEqual(comments[2], self.expectedComment(at: 2))
			case let .failure(error):
				XCTFail("Expected successful comment list result, got \(error) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 5.0)
	}
	
	// MARK: - Helpers
	
	private func makeRemoteImageCommentLoader(file: StaticString = #filePath, line: UInt = #line) -> ImageCommentLoader {
		let session = URLSession(configuration: .ephemeral)
		let client = URLSessionHTTPClient(session: session)
		let loader = RemoteImageCommentLoader(client: client)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return loader
	}
	
	private func expectedComment(at index: Int) -> ImageComment {
		return ImageComment(
			id: id(at: index),
			message: message(at: index),
			creationDate: date(at: index),
			author: author(at: index)
		)
	}
	
	private func id(at index: Int) -> UUID {
		let samples = [
			"7019D8A7-0B35-4057-B7F9-8C5471961ED0",
			"1F4A3B22-9E6E-46FC-BB6C-48B33269951B",
			"00D0CD9A-452C-4812-B264-1B73823C94CA"
		]
		return UUID(uuidString: samples[index])!
	}
	
	private func message(at index: Int) -> String {
		let samples = [
			"The gallery was seen in Wolfgang Becker's movie Goodbye, Lenin!",
			"It was also featured in English indie/rock band Bloc Party's single Kreuzberg taken from the album A Weekend in the City.",
			"The restoration process has been marked by major conflict. Eight of the artists of 1990 refused to paint their own images again after they were completely destroyed by the renovation. In order to defend the copyright, they founded Founder Initiative East Side with other artists whose images were copied without permission."
		]
		return samples[index]
	}
	
	private func date(at index: Int) -> Date {
		let samples = [
			"2020-10-09T11:24:59+0000",
			"2020-10-01T04:23:53+0000",
			"2020-09-26T11:22:59+0000"
		]
		return ISO8601DateFormatter().date(from: samples[index])!
	}
	
	private func author(at index: Int) -> String {
		let samples = [
			"Joe",
			"Megan",
			"Dwight"
		]
		return samples[index]
	}
}

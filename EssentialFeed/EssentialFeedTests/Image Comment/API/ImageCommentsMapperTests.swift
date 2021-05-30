//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {
	func test_map_throwsErrorOnNon200HTTPResponse() throws {
		let json = makeItemsJSON([])
		let samples = [199, 150, 300, 400, 500]

		try samples.forEach { code in
			XCTAssertThrowsError(
				try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code))
			)
		}
	}

	func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
		let invalidJSON = Data("invalid json".utf8)

		XCTAssertThrowsError(
			try ImageCommentsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
		)
	}

	func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
		let emptyListJSON = makeItemsJSON([])

		let result = try ImageCommentsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))

		XCTAssertEqual(result, [])
	}

	func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
		let item1 = makeItem(id: UUID(),
		                     message: "a message",
		                     createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
		                     username: "a username")

		let item2 = makeItem(id: UUID(),
		                     message: "another message",
		                     createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
		                     username: "another username")

		let json = makeItemsJSON([item1.json, item2.json])

		let result = try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: 200))

		XCTAssertEqual(result, [item1.model, item2.model])
	}

	// MARK: - Helpers

	private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
		let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)

		let json: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.iso8601String,
			"author": [
				"username": username
			]
		]
		return (item, json)
	}
}

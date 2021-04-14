//
//  ImageCommentsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Sebastian Vidrea on 19.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {
	func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
		let json = makeItemsJSON([])
		let samples = [199, 170, 300, 400, 500]

		try samples.forEach { code in
			XCTAssertThrowsError(
				try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code))
			)
		}
	}

	func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() {
		let invalidJSON = Data("invalid json".utf8)

		XCTAssertThrowsError(
			try ImageCommentsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
		)
	}

	func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
		let emptyListJSON = makeItemsJSON([])
		let samples = [200, 210, 222, 299]

		try samples.forEach { code in
			let result = try ImageCommentsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: code))
			XCTAssertEqual(result, [])
		}
	}

	func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
		let item1 = makeItem(
			id: UUID(),
			message: "a message",
			createdAt: (Date(timeIntervalSince1970: 1589973899.0), "2020-05-20T11:24:59+0000"),
			username: "a username"
		)

		let item2 = makeItem(
			id: UUID(),
			message: "another message",
			createdAt: (Date(timeIntervalSince1970: 1589898233.0), "2020-05-19T14:23:53+0000"),
			username: "another username"
		)

		let json = makeItemsJSON([item1.json, item2.json])
		let samples = [200, 201, 250, 298]

		try samples.forEach { code in
			let result = try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code))
			XCTAssertEqual(result, [item1.model, item2.model])
		}
	}

	// MARK: - Helpers

	private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
		let author = ImageCommentAuthor(username: username)
		let item = ImageComment(id: id, message: message, createdAt: createdAt.date, author: author)

		let json: [String: Any] = [
			"id": item.id.uuidString,
			"message": item.message,
			"created_at": createdAt.iso8601String,
			"author": [
				"username": author.username
			]
		]

		return (item, json)
	}
}

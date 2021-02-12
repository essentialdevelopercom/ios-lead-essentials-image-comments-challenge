//
//  ImageCommentsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 08/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

final class ImageCommentsMapperTests: XCTestCase {

	func test_map_deliversErrorOnNon2xxHTTPResponse() throws {
		let json = makeItemsJSON([])
		let samples = [199, 300, 350, 400, 500]

		try samples.forEach { code in
			XCTAssertThrowsError(
				try ImageCommentsMapper.map(
					json,
					from: HTTPURLResponse(statusCode: code)
				)
			)
		}
	}

	func test_map_deliversErrorOn2xxHTTPResponseWithInvalidJSON() throws {
		let invalidJSON = Data("invalid json".utf8)
		let samples = [200, 201, 250, 275, 299]

		try samples.forEach { code in
			XCTAssertThrowsError(
				try ImageCommentsMapper.map(
					invalidJSON,
					from: HTTPURLResponse(statusCode: code)
				)
			)
		}
	}

	func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
		let emptyListJSON = makeItemsJSON([])
		let samples = [200, 201, 250, 275, 299]

		try samples.forEach { code in
			let result = try ImageCommentsMapper.map(
				emptyListJSON,
				from: HTTPURLResponse(statusCode: code)
			)

			XCTAssertEqual(result, [])
		}
	}

	func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
		let item1 = makeItem(
			message: "a message",
			createdAt: (
				Date(timeIntervalSince1970: 1610000000),
				"2021-01-07T06:13:20+00:00"
			),
			username: "a username"
		)

		let item2 = makeItem(
			message: "another message",
			createdAt: (
				Date(timeIntervalSince1970: 1612907740),
				"2021-02-09T21:55:40+00:00"
			),
			username: "another username"
		)

		let json = makeItemsJSON([item1.json, item2.json])
		let samples = [200, 201, 250, 275, 299]

		try samples.forEach { code in
			let result = try ImageCommentsMapper.map(
				json,
				from: HTTPURLResponse(statusCode: code)
			)

			XCTAssertEqual(result, [item1.model, item2.model])
		}
	}

	// MARK: - Helpers

	private func makeItem(
		id: UUID = UUID(),
		message: String,
		createdAt: (date: Date, iso8601String: String),
		username: String
	) -> (model: ImageComment, json: [String: Any]) {
		let item = ImageComment(
			id: id,
			message: message,
			createdAt: createdAt.date,
			username: username
		)

		let json = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.iso8601String,
			"author": [
				"username": username
			]
		].compactMapValues { $0 }

		return (item, json)
	}

	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
}

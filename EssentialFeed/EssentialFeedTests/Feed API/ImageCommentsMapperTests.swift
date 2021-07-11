//
//  ImageCommentsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {
	
	func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
		let json = makeItemsJSON([])
		let samples = [199, 300, 400, 500]
		
		try samples.forEach { code in
			XCTAssertThrowsError(try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code)))
		}
	}
	
	func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
		let invalidJSON = Data("Invalid json".utf8)
		let samples = [200, 201, 249, 290, 299]
		
		try samples.forEach { code in
			XCTAssertThrowsError(try ImageCommentsMapper.map(invalidJSON, HTTPURLResponse(statusCode: code)))
		}
	}
	
	func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
		let json = makeItemsJSON([])
		let samples = [200, 201, 249, 290, 299]
		
		try samples.forEach { code in
			XCTAssertEqual(try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code)), [])
		}
	}
	
	func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
		let item1 = makeItem(
			id: UUID(),
			message: "message 1",
			createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
			author: "author 1")
		
		let item2 = makeItem(
			id: UUID(),
			message: "message 2",
			createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
			author: "author 2")
		
		let json = makeItemsJSON([item1.json, item2.json])
		
		let samples = [200, 201, 249, 290, 299]
		
		try samples.forEach { code in
			XCTAssertEqual(try ImageCommentsMapper.map(json, HTTPURLResponse(statusCode: code)), [item1.model, item2.model])
		}
	}
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let url = URL(string: "https://a-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteCommentsLoader? = RemoteCommentsLoader(url: url, client: client)
		
		var capturesResults = [RemoteCommentsLoader.Result]()
		_ = sut?.load { capturesResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: anyData())
		
		XCTAssertTrue(capturesResults.isEmpty)
	}
	
	// MARK - Helpers
	
	private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), author: String ) -> (model: Comment, json: [String: Any]) {
		let model = Comment(id: id, message: message, createdAt: createdAt.date, author: author)
		let json = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.iso8601String,
			"author": [
				"username": author
			]
		] as [String : Any]
		return (model: model, json: json)
	}
	
	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
}

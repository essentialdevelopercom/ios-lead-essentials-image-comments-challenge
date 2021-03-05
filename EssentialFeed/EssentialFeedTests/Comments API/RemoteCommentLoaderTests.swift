//
//  RemoteCommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Eric Garlock on 2/28/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteCommentLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertEqual(client.requestedURLs, [])
	}
	
	func test_load_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_load_requestsDataFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(RemoteCommentLoader.Error.connectivity)) {
			client.complete(with: anyNSError())
		}
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let codes = [199, 201, 300, 400, 500]
		
		codes.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(RemoteCommentLoader.Error.invalidData)) {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			}
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		let invalidJSONData = "invalid json".data(using: .utf8)!
		
		expect(sut, toCompleteWith: .failure(RemoteCommentLoader.Error.invalidData)) {
			client.complete(withStatusCode: 200, data: invalidJSONData)
		}
	}
	
	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		let emptyListJSONData = "{\"items\": []}".data(using: .utf8)!
		
		expect(sut, toCompleteWith: .success([])) {
			client.complete(withStatusCode: 200, data: emptyListJSONData)
		}
	}
	
	func test_load_deliversItemsOn200HTTPResponseWithJSONList() {
		let (sut, client) = makeSUT()
		
		let item1 = makeItem(
			id: UUID(),
			message: "a message",
			createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
			username: "a username")
		
		let item2 = makeItem(
			id: UUID(),
			message: "another message",
			createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
			username: "another username")
		
		let json = ["items": [item1.json, item2.json]]
		let jsonData = try! JSONSerialization.data(withJSONObject: json)
		
		expect(sut, toCompleteWith: .success([item1.model, item2.model])) {
			client.complete(withStatusCode: 200, data: jsonData)
		}
	}
	
	func test_load_doesNotDeliverResultsAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		var sut: RemoteCommentLoader? = RemoteCommentLoader(url: anyURL(), client: client)
		
		var capturedResults = [RemoteCommentLoader.Result]()
		sut?.load { capturedResults.append($0) }
		
		sut = nil
		client.complete(with: anyNSError())
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	// MARK: - Helpers
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: CommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteCommentLoader(url: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: Comment, json: [String:Any]) {
		let item = Comment(
			id: id,
			message: message,
			createdAt: createdAt.date,
			author: CommentAuthor(username: username))
		let json: [String:Any] = [
			"id": item.id.uuidString,
			"message": item.message,
			"created_at": createdAt.iso8601String,
			"author": [
				"username": item.author.username
			]
		]
		return (item, json)
	}
	
	private func expect(_ sut: CommentLoader, toCompleteWith expectedResult: CommentLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
				
			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			default:
				XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
	
	
}

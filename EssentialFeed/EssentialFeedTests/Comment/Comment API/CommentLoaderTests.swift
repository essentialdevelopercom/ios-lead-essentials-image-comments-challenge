//
//  CommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Khoi Nguyen on 24/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CommentLoaderTests: XCTestCase {
	func test_init_doesNotRequestComment() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty, "Expected no requested url upon creation")
	}
	
	func test_load_requestsFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.connectivity)) {
			client.complete(with: anyNSError())
		}
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let codeSamples = [199, 201, 303, 404, 500]
		
		codeSamples.enumerated().forEach { (index, code) in
			expect(sut, toCompleteWith: failure(.invalidData)) {
				let data = makeCommentsJSON(comments: [])
				client.complete(withStatusCode: code, data: data, at: index)
			}
		}
	}
	
	func test_load_deliverErrorOn200HTTPResponseWithInvalidData() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.invalidData)) {
			let invalidData = Data("invalid-data".utf8)
			client.complete(withStatusCode: 200, data: invalidData)
		}
	}
	
	func test_load_deliversNoItemOn200HTTPRepsonseWithEmptyJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .success([])) {
			let emptyJSON = makeCommentsJSON(comments: [])
			client.complete(withStatusCode: 200, data: emptyJSON)
		}
	}
	
	func test_load_deliversSuccessOn200HTTPRepsonseWithData() {
		let (sut, client) = makeSUT()
		let comment1 = makeComment(id: UUID(), message: "any message", createAt: Date(), userName: "any user name")
		let comment2 = makeComment(id: UUID(), message: "another message", createAt: Date(), userName: "another user name")
		let commentJSON = makeCommentsJSON(comments: [comment1.json, comment2.json])
		
		expect(sut, toCompleteWith: .success([comment1.model, comment2.model])) {
			client.complete(withStatusCode: 200, data: commentJSON)
		}
	}
	
	func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
		let client = HTTPClientSpy()
		var sut: RemoteCommentLoader? = RemoteCommentLoader(url: anyURL(), client: client)
		var receivedResult: RemoteCommentLoader.Result?
		
		sut?.load { receivedResult = $0 }
		sut = nil
		client.complete(with: anyNSError())
		
		XCTAssertNil(receivedResult, "Expected to get no result after sut has been deallocated")
	}
	
	func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		let task = sut.load { _ in }
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
		
		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
	}
	
	// MARK: - Helpers
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: CommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteCommentLoader(url: url, client: client)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		
		return (sut, client)
	}
	
	private func expect(_ sut: CommentLoader, toCompleteWith expectedResult: CommentLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		
		let exp = expectation(description: "Wait for load completion")
		sut.load() { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.failure(receivedError as RemoteCommentLoader.Error), .failure(expectedError as RemoteCommentLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			default: break
			}
			exp.fulfill()
		}
		action()
		wait(for: [exp], timeout: 1.0)
	}
	
	private func makeCommentsJSON(comments: [[String: Any]]) -> Data {
		let items = ["items": comments]
		return try! JSONSerialization.data(withJSONObject: items, options: [])
	}
	
	private func makeComment(id: UUID, message: String, createAt: Date, userName: String) -> (model: Comment, json: [String: Any]) {
		let json: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": ISO8601DateFormatter().string(from: createAt),
			"author": ["username": userName]
		]
		
		let model = Comment(id: id, message: message, createAt: createAt, author: CommentAuthor(username: userName))
		
		return (model, json)
	}
	
	private func failure(_ error: RemoteCommentLoader.Error) -> CommentLoader.Result {
		return .failure(error)
	}
}

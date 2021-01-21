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
		
		_ = sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		_ = sut.load() { _ in }
		_ = sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.connectivity)) {
			client.complete(with: anyNSError())
		}
	}
	
	func test_load_deliversErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()
		
		let codeSamples = [199, 300, 303, 404, 500]
		
		codeSamples.enumerated().forEach { (index, code) in
			expect(sut, toCompleteWith: failure(.invalidData)) {
				let data = makeCommentsJSON(comments: [])
				client.complete(withStatusCode: code, data: data, at: index)
			}
		}
	}
	
	func test_load_deliverErrorOn2xxHTTPResponseWithInvalidData() {
		let (sut, client) = makeSUT()
		(200...299).enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData)) {
				let invalidData = Data("invalid-data".utf8)
				client.complete(withStatusCode: code, data: invalidData, at: index)
			}
		}
	}
	
	func test_load_deliversNoItemOn2xxHTTPRepsonseWithEmptyJSON() {
		let (sut, client) = makeSUT()
		(200...299).enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success([])) {
				let emptyJSON = makeCommentsJSON(comments: [])
				client.complete(withStatusCode: code, data: emptyJSON, at: index)
			}
		}
	}
	
	func test_load_deliversSuccessOn2xxHTTPRepsonseWithData() {
		let (sut, client) = makeSUT()
		let comment1 = makeComment(
			id: UUID(),
			message: "any message",
			createAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
			userName: "any user name")
		let comment2 = makeComment(
			id: UUID(),
			message: "another message",
			createAt: (Date(timeIntervalSince1970: 1610238262), "2021-01-10T00:24:22+00:00"),
			userName: "another user name")
		let commentJSON = makeCommentsJSON(comments: [comment1.json, comment2.json])
		
		(200...299).enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success([comment1.model, comment2.model])) {
				client.complete(withStatusCode: code, data: commentJSON, at: index)
			}
		}
	}
	
	func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
		let client = HTTPClientSpy()
		var sut: RemoteCommentLoader? = RemoteCommentLoader(url: anyURL(), client: client)
		var receivedResult: RemoteCommentLoader.Result?
		
		_ = sut?.load { receivedResult = $0 }
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
	
	func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
		let (sut, client) = makeSUT()
		let nonEmptyData = Data("non-empty data".utf8)
		
		var received = [CommentLoader.Result]()
		let task = sut.load { received.append($0) }
		task.cancel()
		
		client.complete(withStatusCode: 404, data: anyData())
		client.complete(withStatusCode: 200, data: nonEmptyData)
		client.complete(with: anyNSError())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
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
		_ = sut.load() { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.failure(receivedError as RemoteCommentLoader.Error), .failure(expectedError as RemoteCommentLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			case let (.success(receivedComments), .success(expectedComments)):
				XCTAssertEqual(receivedComments, expectedComments, file: file, line: line)
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
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
	
	private func makeComment(id: UUID, message: String, createAt: (date: Date, iso8601String: String), userName: String) -> (model: Comment, json: [String: Any]) {
		let json: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": createAt.iso8601String,
			"author": ["username": userName]
		]
		
		let model = Comment(id: id, message: message, createAt: createAt.date, author: CommentAuthor(username: userName))
		
		return (model, json)
	}
	
	private func failure(_ error: RemoteCommentLoader.Error) -> CommentLoader.Result {
		return .failure(error)
	}
}

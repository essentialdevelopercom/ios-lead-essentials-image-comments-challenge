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
			client.completeWith(error: anyNSError())
		}
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let codeSamples = [199, 201, 303, 404, 500]
		
		codeSamples.enumerated().forEach { (index, code) in
			expect(sut, toCompleteWith: failure(.invalidData)) {
				let non200HTTPResponse = hTTPResponse(code: code)
				client.completeWith(data: makeCommentsJSON(comments: []), response: non200HTTPResponse, at: index)
			}
		}
	}
	
	func test_load_deliverErrorOn200HTTPResponseWithInvalidData() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.invalidData)) {
			let twoHundredTTPResponse = hTTPResponse(code: 200)
			let invalidData = Data("invalid-data".utf8)
			client.completeWith(data: invalidData, response: twoHundredTTPResponse)
		}
	}
	
	func test_load_deliversNoItemOn200HTTPRepsonseWithEmptyJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .success([])) {
			let twoHundredTTPResponse = hTTPResponse(code: 200)
			let emptyJSON = makeCommentsJSON(comments: [])
			client.completeWith(data: emptyJSON, response: twoHundredTTPResponse)
		}
	}
	
	func test_load_deliversSuccessOn200HTTPRepsonseWithData() {
		let (sut, client) = makeSUT()
		let comment1 = makeComment(id: UUID(), message: "any message", createAt: Date(), userName: "any user name")
		let comment2 = makeComment(id: UUID(), message: "another message", createAt: Date(), userName: "another user name")
		let commentJSON = makeCommentsJSON(comments: [comment1.json, comment2.json])
		
		expect(sut, toCompleteWith: .success([comment1.model, comment2.model])) {
			let twoHundredTTPResponse = hTTPResponse(code: 200)
			
			client.completeWith(data: commentJSON, response: twoHundredTTPResponse)
		}
	}
	
	func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
		let client = ClientSpy()
		var sut: RemoteCommentLoader? = RemoteCommentLoader(url: anyURL(), client: client)
		var receivedResult: RemoteCommentLoader.Result?
		
		sut?.load { receivedResult = $0 }
		sut = nil
		client.completeWith(error: anyNSError())
		
		XCTAssertNil(receivedResult, "Expected to get no result after sut has been deallocated")
	}
	
	// MARK: - Helpers
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: CommentLoader, client: ClientSpy) {
		let client = ClientSpy()
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
	
	class ClientSpy: HTTPClient {
		
		var requestedURLs: [URL] {
			messages.map { $0.url }
		}
		var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
		
		private class Task: HTTPClientTask {
			func cancel() {
				
			}
		}
		
		func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
			messages.append((url, completion))
			return Task()
		}
		
		func completeWith(error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
		
		func completeWith(data: Data, response: HTTPURLResponse, at index: Int = 0) {
			messages[index].completion(.success((data, response)))
		}
	}
	
	private func hTTPResponse(code: Int) -> HTTPURLResponse {
		return HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!
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

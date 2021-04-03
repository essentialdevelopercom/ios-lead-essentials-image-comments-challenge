//
//  RemoteImageCommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 17/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT(url: anyURL())
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		_ = sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestDataFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		_ = sut.load { _ in }
		_ = sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversConnectivityErrorOnClientError() {
		let (sut, client) = makeSUT(url: anyURL())
		let error = anyNSError()
		
		expect(sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: error)
		})
	}
	
	func test_load_deliversInvalidDataErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT(url: anyURL())
		let samples = [199, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				client.complete(withStatusCode: code, data: makeCommentsJSON([]), at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT(url: anyURL())
		let samples = [200, 201, 202, 206, 207, 226]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let invalidJSON = Data("invalid json".utf8)
				client.complete(withStatusCode: code, data: invalidJSON, at: index)
			})
		}
	}
	
	func test_load_deliversNoCommentsOn2xxHTTPResponseWithEmptyList() {
		let (sut, client) = makeSUT(url: anyURL())
		let samples = [200, 201, 202, 206, 207, 226]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success([]), when: {
				let emptyListJSON = makeCommentsJSON([])
				client.complete(withStatusCode: code, data: emptyListJSON, at: index)
			})
		}
	}
	
	func test_load_deliversCommentsOn2xxHTTPResponseWithCommentsList() {
		let (sut, client) = makeSUT(url: anyURL())
		
		let comment1 = makeComment(
			id: UUID(),
			message: "a message",
			creationDate: (timestamp: 1_589_973_899, iso8601Representation: "2020-05-20T11:24:59+0000"),
			author: "a username"
		)
		let comment2 = makeComment(
			id: UUID(),
			message: "another message",
			creationDate: (timestamp: 1_589_898_233, iso8601Representation: "2020-05-19T14:23:53+0000"),
			author: "another username"
		)
		let samples = [200, 201, 202, 206, 207, 226]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success([comment1.model, comment2.model]), when: {
				let json = makeCommentsJSON([comment1.json, comment2.json])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}
	
	func test_load_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		var sut: ImageCommentLoader? = RemoteImageCommentLoader(url: anyURL(), client: client)
		
		var capturedResults = [ImageCommentLoader.Result]()
		_ = sut?.load { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeCommentsJSON([]))
		
		XCTAssertTrue(capturedResults.isEmpty, "Not expecting a result after instance has been dealloacted")
	}
	
	func test_cancelLoadCommentsDataURLTask_cancelsClientURLRequest() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		let task = sut.load { _ in }
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL requests until task is cancelled")
		
		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
	}
	
	func test_load_doesNotDeliverResultAfterCancellingTask() {
		let (sut, client) = makeSUT(url: anyURL())
		let emptyComments = makeCommentsJSON([])
		
		var receivedResults = [ImageCommentLoader.Result]()
		let task = sut.load { receivedResults.append($0) }
		task.cancel()
		
		client.complete(withStatusCode: 500, data: anyData())
		client.complete(withStatusCode: 200, data: emptyComments)
		client.complete(with: anyNSError())
		
		XCTAssertTrue(receivedResults.isEmpty, "Expected no received results after cancelling task")
	}
	
	// MARK: - Helpers
	
	private func failure(_ error: RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result {
		return .failure(error)
	}
	
	private func makeComment(
		id: UUID,
		message: String,
		creationDate: (timestamp: TimeInterval, iso8601Representation: String),
		author: String
	) -> (model: ImageComment, json: [String: Any]) {
		let comment = ImageComment(id: id, message: message, creationDate: Date(timeIntervalSince1970: creationDate.timestamp), author: author)
		let json: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": creationDate.iso8601Representation,
			"author": [
				"username": author
			]
		]
		return (comment, json)
	}
	
	private func makeCommentsJSON(_ comments: [[String: Any]]) -> Data {
		let json = ["items": comments]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func makeSUT(url: URL, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentLoader(url: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func expect(_ sut: RemoteImageCommentLoader, toCompleteWith expectedResult: ImageCommentLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		_ = sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedComments), .success(expectedComments)):
				XCTAssertEqual(receivedComments, expectedComments, file: file, line: line)
			case let (.failure(receivedError as RemoteImageCommentLoader.Error), .failure(expectedError as RemoteImageCommentLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
}

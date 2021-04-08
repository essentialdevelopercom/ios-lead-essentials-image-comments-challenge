//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Bogdan Poplauschi on 27/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		_ = sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		_ = sut.load { _ in }
		_ = sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: NSError(domain: "Test", code: 0))
		})
	}
	
	func test_load_deliversErrorOnNon2XXHTTPResponse() {
		let (sut, client) = makeSUT()
		let samples = [199, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				client.complete(withStatusCode: code, data: makeItemsJSON([]), at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn2XXHTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		let samples = [200, 201, 299]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let invalidJSON = Data("invalid json".utf8)
				client.complete(withStatusCode: code, data: invalidJSON, at: index)
			})
		}
	}
	
	func test_load_deliversNoItemsOn2XXHTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		let samples = [200, 201, 299]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success([]), when: {
				let emptyListJSON = makeItemsJSON([])
				client.complete(withStatusCode: code, data: emptyListJSON, at: index)
			})
		}
	}
	
	func test_load_deliversItemsOn2XXHTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		
		let item1 = makeItem(id: UUID(), message: "a message", createdAt: (date: Date(timeIntervalSinceReferenceDate: 638556190), iso8601String: "2021-03-27T16:43:10+00:00"), authorName: "a username")
		let item2 = makeItem(id: UUID(), message: "another message", createdAt: (date:Date(timeIntervalSinceReferenceDate: 638590000), iso8601String: "2021-03-28T02:06:40+00:00"), authorName: "another username")
		
		let items = [item1.model, item2.model]
		
		let samples = [200, 201, 299]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success(items), when: {
				let json = makeItemsJSON([item1.json, item2.json])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		var sut: RemoteCommentsLoader? = RemoteCommentsLoader(url: anyURL(), client: client)
		
		var capturedResults = [RemoteCommentsLoader.Result]()
		_ = sut?.load { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	func test_cancelLoadTask_cancelsClientURLRequest() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		let task = sut.load { _ in }
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
		
		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
	}
	
	func test_cancelLoadTask_doesNotDeliverResultAfterCancellingTask() {
		let (sut, client) = makeSUT()
		let nonEmptyData = Data("non-empty data".utf8)
		
		var received = [RemoteCommentsLoader.Result]()
		let task = sut.load { received.append($0) }
		task.cancel()
		
		client.complete(withStatusCode: 404, data: anyData())
		client.complete(withStatusCode: 200, data: nonEmptyData)
		client.complete(with: anyNSError())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
	}
	
	// MARK: - Helpers
	
	private func expect(
		_ sut: RemoteCommentsLoader,
		toCompleteWith expectedResult: RemoteCommentsLoader.Result,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let exp = expectation(description: "Wait for load completion")
		
		_ = sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
			
			case let (.failure(receivedError as NSError?), .failure(expectedError as NSError?)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			default:
				XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteCommentsLoader(url: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), authorName: String) -> (model: ImageComment, json: [String: Any]) {
		let item = ImageComment(id: id, message: message, createdAt: createdAt.date, author: ImageCommentAuthor(username: authorName))
		
		let json = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.iso8601String,
			"author": [
				"username": authorName
			]
		].compactMapValues { $0 }
		
		return (item, json)
	}
	
	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func failure(_ error: RemoteCommentsLoader.Error) -> RemoteCommentsLoader.Result {
		return .failure(error)
	}
}

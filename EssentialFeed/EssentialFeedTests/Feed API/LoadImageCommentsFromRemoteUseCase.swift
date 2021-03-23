//
//  LoadImageCommentsFromRemoteUseCase.swift
//  EssentialFeedTests
//
//  Created by Adrian Szymanowski on 02/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCase: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_loadImageComments_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT()
		
		_ = sut.loadImageComments { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadImageCommentsTwice_requestsImageCommentsTwice() {
		let url = URL(string: "htttp://example-url.com/")!
		let (sut, client) = makeSUT(stubURL: url)
		
		_ = sut.loadImageComments { _ in }
		_ = sut.loadImageComments { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_loadImageComments_deliversConnectivityErrorOnClientError() {
		let (sut, client) = makeSUT()
		let clientError = anyNSError()
		
		expect(sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: clientError)
		})
	}
	
	func test_loadImageComments_deliversInvalidDataErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199, 300, 350, 400, 500].enumerated()
		
		samples.forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let emptyJsonList = makeItemsJSON([])
				client.complete(withStatusCode: code, data: emptyJsonList, at: index)
			})
		}
	}
	
	func test_loadImageComments_deliversInvalidDataErrorOn2xxHTTPResponseWithEmptyData() {
		let (sut, client) = makeSUT()
		
		let samples = [200, 201, 210, 240, 280, 299].enumerated()
		
		samples.forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let emptyData = Data()
				client.complete(withStatusCode: code, data: emptyData, at: index)
			})
		}
	}
	
	func test_loadImageComments_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		let samples = [200, 201, 210, 240, 280, 299].enumerated()
		
		samples.forEach { index, code in
			expect(sut, toCompleteWith: .success([]), when: {
				let emptyJsonList = makeItemsJSON([])
				client.complete(withStatusCode: code, data: emptyJsonList, at: index)
			})
		}
	}
	
	func test_loadImageComments_deliversItemsOn2xxHTTPResponseWithSomeItems() {
		let (sut, client) = makeSUT()
		let item1 = makeItem(
			id: UUID(),
			message: "A message",
			createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
			username: "An username")
		
		let item2 = makeItem(
			id: UUID(),
			message: "Another message",
			createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
			username: "Another username")
		
		let items = [item1.model, item2.model]
		let samples = [200, 201, 210, 240, 280, 299].enumerated()
		
		samples.forEach { index, code in
			expect(sut, toCompleteWith: .success(items), when: {
				let json = makeItemsJSON([item1.json, item2.json])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}
	
	func test_cancelLoadImageComments_cancelsClientURLRequest() {
		let url = URL(string: "htttp://example-url.com/")!
		let (sut, client) = makeSUT(stubURL: url)
		
		let task = sut.loadImageComments { _ in }
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL requests until task is cancelled")
		
		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
	}
	
	func test_loadImageComments_doesNotDeliverResultAfterCancellingTask() {
		let (sut, client) = makeSUT()
		let nonEmptyData = Data("non-empty data".utf8)
		
		var received = [RemoteImageCommentsLoader.Result]()
		let task = sut.loadImageComments { received.append($0) }
		task.cancel()
		
		client.complete(withStatusCode: 404, data: anyData())
		client.complete(withStatusCode: 200, data: nonEmptyData)
		client.complete(with: anyNSError())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
	}
	
	func test_loadImageComments_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		let url = URL(string: "htttp://example-url.com/")!
		var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
		
		var capturedResults = [RemoteImageCommentsLoader.Result]()
		_ = sut?.loadImageComments { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: anyData())
		
		XCTAssertTrue(capturedResults.isEmpty)
	}

	// MARK: - Helpers
	
	private func makeSUT(stubURL: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(url: stubURL, client: client)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, client)
	}
	
	private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
		.failure(error)
	}
	
	private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
		let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
		
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
	
	private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for load comments completion")
		
		_ = sut.loadImageComments { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)
			
			case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			default:
				XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
	
}

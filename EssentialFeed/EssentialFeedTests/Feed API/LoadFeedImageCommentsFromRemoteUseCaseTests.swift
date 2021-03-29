//
//  LoadFeedImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ivan Ornes on 9/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedImageCommentsFromRemoteUseCaseTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_loadImageCommentsFromURL_requestsCommentsFromURL() {
		let imageID = UUID().uuidString
		let url = URL(string: "https://a-given-url.com/image/\(imageID)/comments")!
		let (sut, client) = makeSUT()
		
		_ = sut.loadImageComments(imageID: imageID) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadImageCommentsFromURLTwice_requestsCommentsFromURLTwice() {
		let imageID = UUID().uuidString
		let url = URL(string: "https://a-given-url.com/image/\(imageID)/comments")!
		let (sut, client) = makeSUT()
		
		_ = sut.loadImageComments(imageID: imageID) { _ in }
		_ = sut.loadImageComments(imageID: imageID) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_loadImageCommentsFromURL_deliversConnectivityErrorOnClientError() {
		let (sut, client) = makeSUT()
		let clientError = NSError(domain: "a client error", code: 0)
		
		expect(sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: clientError)
		})
	}
	
	func test_loadImageCommentsFromURL_deliversInvalidDataErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199, 150, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			})
		}
	}
	
	func test_loadImageCommentsFromURL_deliversInvalidDataErrorOn2xxHTTPResponseWithEmptyData() {
		let (sut, client) = makeSUT()
		
		let samples = [200, 201, 299]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let emptyData = Data()
				client.complete(withStatusCode: code, data: emptyData, at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.invalidData), when: {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}
	
	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .success([]), when: {
			let emptyListJSON = makeItemsJSON([])
			client.complete(withStatusCode: 200, data: emptyListJSON)
		})
	}
	
	func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		
		let item1 = makeItem(id: UUID(),
							 message: "a message",
							 createdAt: "2020-05-20T11:24:59+0000".ISO8601Date,
							 username: "a username")
		
		let item2 = makeItem(id: UUID(),
							 message: "a message",
							 createdAt: "2020-05-19T14:23:53+0000".ISO8601Date,
							 username: "another username")
		
		let items = [item1.model, item2.model]
		
		expect(sut, toCompleteWith: .success(items), when: {
			let json = makeItemsJSON([item1.json, item2.json])
			client.complete(withStatusCode: 200, data: json)
		})
	}
	
	func test_cancelLoadImageCommentsURLTask_cancelsClientURLRequest() {
		let imageID = UUID().uuidString
		let url = URL(string: "https://a-given-url.com/image/\(imageID)/comments")!
		let (sut, client) = makeSUT()
		
		let task = sut.loadImageComments(imageID: imageID) { _ in }
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
		
		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
	}
	
	func test_loadImageCommentsFromURL_doesNotDeliverResultAfterCancellingTask() {
		let (sut, client) = makeSUT()
		let imageID = UUID().uuidString
		let nonEmptyData = Data("non-empty data".utf8)
		
		var received = [FeedImageCommentsLoader.Result]()
		let task = sut.loadImageComments(imageID: imageID) { received.append($0) }
		task.cancel()
		
		client.complete(withStatusCode: 404, data: anyData())
		client.complete(withStatusCode: 200, data: nonEmptyData)
		client.complete(with: anyNSError())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
	}
	
	func test_loadImageCommentsFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		let url = URL(string: "https://a-given-url.com")!
		let imageID = UUID().uuidString
		var sut: RemoteFeedImageCommentsLoader? = RemoteFeedImageCommentsLoader(baseURL: url, client: client)
		
		var capturedResults = [FeedImageCommentsLoader.Result]()
		_ = sut?.loadImageComments(imageID: imageID) { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: anyData())
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let url = URL(string: "https://a-given-url.com")!
		let sut = RemoteFeedImageCommentsLoader(baseURL: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func failure(_ error: RemoteFeedImageCommentsLoader.Error) -> FeedImageCommentsLoader.Result {
		return .failure(error)
	}
	
	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func makeItem(id: UUID, message: String, createdAt: Date, username: String) -> (model: FeedImageComment, json: [String: Any]) {
		let item = FeedImageComment(id: id, message: message, createdAt: createdAt, author: .init(username: username))
		let json = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.ISO8601String,
			"author": ["username": username]
		].compactMapValues { $0 }
		
		return (item, json)
	}

	private func expect(_ sut: RemoteFeedImageCommentsLoader, toCompleteWith expectedResult: FeedImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		let imageID = UUID().uuidString
		
		_ = sut.loadImageComments(imageID: imageID) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)
				
			case let (.failure(receivedError as RemoteFeedImageCommentsLoader.Error), .failure(expectedError as RemoteFeedImageCommentsLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
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

private extension Date {
	var ISO8601String: String {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = .withInternetDateTime
		return formatter.string(from: self)
	}
}

private extension String {
	var ISO8601Date: Date {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = .withInternetDateTime
		return formatter.date(from: self)!
	}
}

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
		let image = uniqueImage()
		let (sut, client) = makeSUT(image: image)
		let url = URL(string: "https://a-given-url.com/image/\(image.id.uuidString)/comments")!
		
		_ = sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadImageCommentsFromURLTwice_requestsCommentsFromURLTwice() {
		let image = uniqueImage()
		let url = URL(string: "https://a-given-url.com/image/\(image.id.uuidString)/comments")!
		let (sut, client) = makeSUT(image: image)
		
		_ = sut.load() { _ in }
		_ = sut.load() { _ in }
		
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
				client.complete(withStatusCode: code, data: makeItemsJSON([]), at: index)
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
	
	func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		let samples = [200, 201, 299]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let invalidJSON = Data("invalid json".utf8)
				client.complete(withStatusCode: code, data: invalidJSON, at: index)
			})
		}
	}
	
	func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		let samples = [200, 201, 299]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success([]), when: {
				let emptyListJSON = makeItemsJSON([])
				client.complete(withStatusCode: code, data: emptyListJSON, at: index)
			})
		}
	}
	
	func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		
		let item1 = makeItem(id: UUID(),
							 message: "a message",
							 createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
							 username: "a username")
		
		let item2 = makeItem(id: UUID(),
							 message: "another message",
							 createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
							 username: "another username")
		
		let items = [item1.model, item2.model]
		
		let samples = [200, 201, 299]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success(items), when: {
				let json = makeItemsJSON([item1.json, item2.json])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}
	
	func test_cancelLoadImageCommentsURLTask_cancelsClientURLRequest() {
		let image = uniqueImage()
		let url = URL(string: "https://a-given-url.com/image/\(image.id.uuidString)/comments")!
		let (sut, client) = makeSUT(image: image)
		
		let task = sut.load() { _ in }
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
		
		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
	}
	
	func test_loadImageCommentsFromURL_doesNotDeliverResultAfterCancellingTask() {
		let (sut, client) = makeSUT()
		let nonEmptyData = Data("non-empty data".utf8)
		
		var received = [FeedImageCommentsLoader.Result]()
		let task = sut.load() { received.append($0) }
		task.cancel()
		
		client.complete(withStatusCode: 404, data: anyData())
		client.complete(withStatusCode: 200, data: nonEmptyData)
		client.complete(with: anyNSError())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
	}
	
	func test_loadImageCommentsFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		let image = uniqueImage()
		let url = URL(string: "https://a-given-url.com/image/\(image.id.uuidString)/comments")!
		var sut: RemoteFeedImageCommentsLoader? = RemoteFeedImageCommentsLoader(baseURL: url, client: client, feedImage: image)
		
		var capturedResults = [FeedImageCommentsLoader.Result]()
		_ = sut?.load { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: anyData())
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(baseURL: URL = URL(string: "https://a-given-url.com")!, file: StaticString = #filePath, line: UInt = #line, image: FeedImage = uniqueImage()) -> (sut: RemoteFeedImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageCommentsLoader(baseURL: baseURL, client: client, feedImage: image)
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
	
	private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: FeedImageComment, json: [String: Any]) {
		let item = FeedImageComment(id: id, message: message, createdAt: createdAt.date, author: .init(username: username))
		let json = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.iso8601String,
			"author": ["username": username]
		].compactMapValues { $0 }
		
		return (item, json)
	}

	private func expect(_ sut: RemoteFeedImageCommentsLoader, toCompleteWith expectedResult: FeedImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		_ = sut.load() { receivedResult in
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

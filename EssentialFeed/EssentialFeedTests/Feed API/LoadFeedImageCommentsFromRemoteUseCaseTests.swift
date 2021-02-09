//
//  LoadFeedImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mario Alberto Barragán Espinosa on 04/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedImageCommentsFromRemoteUseCaseTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_loadImageCommentDataFromURL_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		let _ = sut.loadImageCommentData(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadImageCommentDataFromURL_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		let _ = sut.loadImageCommentData(from: url) { _ in }
		let _ = sut.loadImageCommentData(from: url) { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_loadImageCommentDataFromURL_deliversConnectivityErrorOnClientError() {
		let (sut, client) = makeSUT()
		let clientError = anyNSError()

		expect(sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: clientError)
		})
	}
	
	func test_loadImageCommentDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()

		let samples = [199, 201, 300, 400, 500]

		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			})
		}
	}
	
	func test_loadImageCommentDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: failure(.invalidData), when: {
			let emptyData = Data()
			client.complete(withStatusCode: 200, data: emptyData)
		})
	}
	
	func test_loadImageCommentDataFromURL_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.invalidData), when: {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}
	
	func test_loadImageCommentDataFromURL_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .success([]), when: {
			let emptyListJSON = makeItemsJSON([])
			client.complete(withStatusCode: 200, data: emptyListJSON)
		})
	}
	
	func test_loadImageCommentDataFromURL_deliversItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		
		let item1 = makeCommentItem(
			id: UUID(),
			message: "mesage",
			createdAt: (Date(timeIntervalSince1970: 754833685), "1993-12-02T12:01:25+0000"),
			authorUsername: "username")
		
		let item2 = makeCommentItem(
			id: UUID(),
			message: "another mesage",
			createdAt: (Date(timeIntervalSince1970: 694958485), "1992-01-09T12:01:25+0000"),
			authorUsername: "another username")
		
		let items = [item1.model, item2.model]
		
		expect(sut, toCompleteWith: .success(items), when: {
			let json = makeItemsJSON([item1.json, item2.json])
			client.complete(withStatusCode: 200, data: json)
		})
	}
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		var sut: RemoteFeedImageCommentLoader? = RemoteFeedImageCommentLoader(client: client)

		var capturedResults = [RemoteFeedImageCommentLoader.Result]()
		let _ = sut?.loadImageCommentData(from: anyURL()) { capturedResults.append($0) }

		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))

		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	func test_cancelLoadImageCommentDataFromURL_cancelsClientURLRequest() {
		let (sut, client) = makeSUT()
		let url = URL(string: "https://a-given-url.com")!

		let task = sut.loadImageCommentData(from: url) { _ in }
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")

		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageCommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageCommentLoader(client: client)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func makeCommentItem(
		id: UUID, 
		message: String = "", 
		createdAt: (date: Date, iso8601Representation: String), 
		authorUsername: String = "") -> (model: FeedImageComment, json: [String: Any]) {
		let item = FeedImageComment(id: id, message: message, creationDate: createdAt.date, authorUsername: authorUsername)
		
		let json = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.iso8601Representation,
			"author": ["username": authorUsername]
			].compactMapValues { $0 }
		return (item, json)
	}
	
	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func failure(_ error: RemoteFeedImageCommentLoader.Error) -> RemoteFeedImageCommentLoader.Result {
		return .failure(error)
	}
	
	private func expect(_ sut: RemoteFeedImageCommentLoader, toCompleteWith expectedResult: RemoteFeedImageCommentLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let url = URL(string: "https://a-given-url.com")!
		let exp = expectation(description: "Wait for load completion")

		let _ = sut.loadImageCommentData(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)
				
			case let (.failure(receivedError as RemoteFeedImageCommentLoader.Error), .failure(expectedError as RemoteFeedImageCommentLoader.Error)):
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

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
		
		_ = sut.loadImageCommentData() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadImageCommentDataFromURL_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		_ = sut.loadImageCommentData() { _ in }
		_ = sut.loadImageCommentData() { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_loadImageCommentDataFromURL_deliversConnectivityErrorOnClientError() {
		let (sut, client) = makeSUT()
		let clientError = anyNSError()

		expect(sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: clientError)
		})
	}
	
	func test_loadImageCommentDataFromURL_deliversInvalidDataErrorOnNon2XXHTTPResponse() {
		let (sut, client) = makeSUT()

		let samples = [199, 300, 400, 500]

		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			})
		}
	}
	
	func test_loadImageCommentDataFromURL_deliversInvalidDataErrorOn2XXHTTPResponseWithEmptyData() {
		let (sut, client) = makeSUT()
		
		let samples = [200, 201, 202, 203, 204, 205, 206, 207, 208, 226]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let emptyData = Data()
				client.complete(withStatusCode: code, data: emptyData, at: index)
			})
		}
	}
	
	func test_loadImageCommentDataFromURL_deliversErrorOn2XXHTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		let samples = [200, 201, 202, 203, 204, 205, 206, 207, 208, 226]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let invalidJSON = Data("invalid json".utf8)
				client.complete(withStatusCode: code, data: invalidJSON, at: index)
			})
		}
	}
	
	func test_loadImageCommentDataFromURL_deliversNoItemsOn2XXHTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		let samples = [200, 201, 202, 203, 204, 205, 206, 207, 208, 226]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success([]), when: {
				let emptyListJSON = makeItemsJSON([])
				client.complete(withStatusCode: code, data: emptyListJSON, at: index)
			})
		}
	}
	
	func test_loadImageCommentDataFromURL_deliversItemsOn2XXHTTPResponseWithJSONItems() {
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
		
		let samples = [200, 201, 202, 203, 204, 205, 206, 207, 208, 226]
		
		samples.enumerated().forEach { index, code in 
			expect(sut, toCompleteWith: .success(items), when: {
				let json = makeItemsJSON([item1.json, item2.json])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}
	
	func test_loadImageCommentDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		var sut: RemoteFeedImageCommentLoader? = RemoteFeedImageCommentLoader(url: anyURL(), client: client)

		var capturedResults = [RemoteFeedImageCommentLoader.Result]()
		_ = sut?.loadImageCommentData() { capturedResults.append($0) }

		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))

		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	func test_cancelLoadImageCommentDataFromURL_cancelsClientURLRequest() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		let task = sut.loadImageCommentData() { _ in }
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")

		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
	}
	
	func test_loadImageCommentDataFromURL_doesNotDeliverResultAfterCancellingTask() {
		let (sut, client) = makeSUT()
		let nonEmptyData = Data("non-empty data".utf8)

		var received = [FeedImageCommentLoader.Result]()
		let task = sut.loadImageCommentData() { received.append($0) }
		task.cancel()

		client.complete(withStatusCode: 404, data: anyData())
		client.complete(withStatusCode: 200, data: nonEmptyData)
		client.complete(with: anyNSError())

		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageCommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageCommentLoader(url: url, client: client)
		
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
		let exp = expectation(description: "Wait for load completion")

		_ = sut.loadImageCommentData() { receivedResult in
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

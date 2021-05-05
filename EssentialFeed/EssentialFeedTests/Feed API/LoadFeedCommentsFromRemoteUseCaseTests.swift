//
//  LoadFeedCommentsFromRemoteUseCaseTests.swift.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class LoadFeedCommentsFromRemoteUseCaseTests: XCTestCase {

	func test_init_doesNotRequestDataFromUrl() {
		let (_, client, _) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let (loader, client, url) = makeSUT()

		_ = loader.load(completion: { _ in })
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let (sut, client, url) = makeSUT()
		
		_ = sut.load() { _ in }
		_ = sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client, _) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.connectivity), when: {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		})
	}
	
	func test_load_deliversErrorOnNon2xxHTTPResponse() {
		let (sut, client, _) = makeSUT()
		
		let samples = [199, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let json = makeItemsJSON([])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
		let (sut, client, _) = makeSUT()
		
		let samples = [200, 205, 206, 290, 299, 289]

		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let invalidJSON = Data("invalid json".utf8)
				client.complete(withStatusCode: code, data: invalidJSON, at: index)
			})
		}
	}
	
	func test_load_deliversNoItemsOn2xxCodeHTTPResponseWithEmptyJSONList() {
		let (sut, client, _) = makeSUT()
		
		let samples = [200, 205, 206, 290, 299, 289]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success([]), when: {
				let emptyListJSON = makeItemsJSON([])
				client.complete(withStatusCode: code, data: emptyListJSON, at: index)
			})
		}
	}
	
	func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() {
		let (sut, client, _) = makeSUT()
		
		let item1 = makeComment(
			id: UUID(),
			createdAt: (Date(timeIntervalSince1970: 1614618409), "2021-03-01T17:06:49+0000")
		)
		
		let item2 = makeComment(
			id: UUID(),
			message: "test comment",
			createdAt: (Date(timeIntervalSince1970: 0), "1970-01-01T00:00:00+0000")
		)
		
		let items = [item1.model, item2.model]
		
		let samples = [200, 205, 206, 290, 299, 289]

		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .success(items), when: {
				let json = makeItemsJSON([item1.json, item2.json])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}

	}
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		
		var sut: RemoteFeedImageCommentLoader? = RemoteFeedImageCommentLoader(url: anyURL(), client: client)
		
		var capturedResults = [RemoteFeedImageCommentLoader.Result]()
		_ = sut?.load() { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedImageCommentLoader, HTTPClientSpy, URL) {
		let url = anyURL()
		let client = HTTPClientSpy()
		let loader = RemoteFeedImageCommentLoader(
			url: url,
			client: client
		)

		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		
		return (loader, client, url)
	}

	private func failure(_ error: RemoteFeedImageCommentLoader.Error) -> RemoteFeedImageCommentLoader.Result {
		return .failure(error)
	}
	
	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func makeComment(id: UUID, message: String = "msg", createdAt: (date: Date, stringValue: String), username: String = "user") -> (model: FeedComment, json: [String: Any]) {
		let comment = FeedComment(id: id, message: message, createdAt: createdAt.date, author: .init(username: username)
		)
		
		let authorJson = [
			"username": username
		]
		let commentJson: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.stringValue,
			"author": authorJson
		]
		
		return (comment, commentJson)
	}
	
	private func expect(_ sut: RemoteFeedImageCommentLoader, toCompleteWith expectedResult: RemoteFeedImageCommentLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		_ = sut.load() { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
				
			case let (.failure(receivedError as RemoteFeedImageCommentLoader.Error), .failure(expectedError as RemoteFeedImageCommentLoader.Error)):
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

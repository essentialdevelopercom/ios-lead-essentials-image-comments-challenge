//
//  FeedImageCommentsTests.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedImageCommentsTests: XCTestCase {

	func test_init_doesNotRequestDataFromUrl() {
		let (_, client, _) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let (loader, client, url) = makeSUT(imageId: "1")

		_ = loader.load(completion: { _ in })
		
		assert(requestedUrls: client.requestedURLs, equalsToExpectedUrls: [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let (sut, client, url) = makeSUT()
		
		_ = sut.load() { _ in }
		_ = sut.load() { _ in }
		
		assert(requestedUrls: client.requestedURLs, equalsToExpectedUrls: [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client, _) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.connectivity), when: {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		})
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client, _) = makeSUT()
		
		let samples = [199, 201, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let json = makeItemsJSON([])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client, _) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.invalidData), when: {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}
	
	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client, _) = makeSUT()
		
		expect(sut, toCompleteWith: .success([]), when: {
			let emptyListJSON = makeItemsJSON([])
			client.complete(withStatusCode: 200, data: emptyListJSON)
		})
	}
	
	func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client, _) = makeSUT()
		
		let item1 = makeComment(
			id: UUID(),
			createdAt: (Date(timeIntervalSince1970: 1614618409), "2021-03-01T17:06:49+0000")
		)
		
		let item2 = makeComment(
			id: UUID(),
			message: "test comment",
			createdAt: (Date(timeIntervalSince1970: 1614618409), "2021-03-01T17:06:49+0000")
		)
		
		let items = [item1.model, item2.model]
		
		expect(sut, toCompleteWith: .success(items), when: {
			let json = makeItemsJSON([item1.json, item2.json])
			client.complete(withStatusCode: 200, data: json)
		})
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
	
	private func makeSUT(imageId: String = "any") -> (RemoteFeedImageCommentLoader, HTTPClientSpy, URL) {
		let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(imageId)/comments")!
		let client = HTTPClientSpy()
		let loader = RemoteFeedImageCommentLoader(
			url: url,
			client: client
		)

		trackForMemoryLeaks(client)
		trackForMemoryLeaks(loader)
		
		return (loader, client, url)
	}
	
	private func assert(requestedUrls: [URL], equalsToExpectedUrls: [URL]) {
		XCTAssertTrue(requestedUrls.count == equalsToExpectedUrls.count, "Expected \(equalsToExpectedUrls.count) urls, Requested \(requestedUrls.count) instead")
		XCTAssertEqual(requestedUrls, equalsToExpectedUrls)
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
		let commentJson = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.stringValue,
			"author": authorJson
		].compactMapValues { $0 }
		
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

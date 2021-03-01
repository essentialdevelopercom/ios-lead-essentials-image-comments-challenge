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
		let (loader, client, imageUrlProvider) = makeSUT()

		loader.load(imageId: "1", completion: { _ in })
		
		assert(requestedUrls: client.requestedURLs,
			   imageUrlProvider: imageUrlProvider,
			   imageIds: "1"
		)
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let (sut, client, imageUrlProvider) = makeSUT()
		
		sut.load(imageId: "1") { _ in }
		sut.load(imageId: "2") { _ in }
		
		assert(requestedUrls: client.requestedURLs,
			   imageUrlProvider: imageUrlProvider,
			   imageIds: "1", "2"
		)
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
	
	private func assert(requestedUrls: [URL], imageUrlProvider: @escaping ((String) -> URL), imageIds: String...) {
		let apiUrls = imageIds.map { imageUrlProvider($0) }
		XCTAssertEqual(requestedUrls, apiUrls)
	}
	
	private func failure(_ error: RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result {
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
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		var sut: RemoteImageCommentLoader? = RemoteImageCommentLoader(imageUrlProvider: { imageId in
			URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(imageId)/comments")!
		}, client: client)
		
		var capturedResults = [RemoteImageCommentLoader.Result]()
		sut?.load(imageId: "1") { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	private func makeSUT() -> (RemoteImageCommentLoader, HTTPClientSpy, (String) -> URL) {
		let imageUrlProvider: (String) -> URL = { imageId in
			URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(imageId)/comments")!
		}
		
		let client = HTTPClientSpy()
		let loader = RemoteImageCommentLoader(
			imageUrlProvider: imageUrlProvider,
			client: client
		)

		trackForMemoryLeaks(client)
		trackForMemoryLeaks(loader)
		
		return (loader, client, imageUrlProvider)
	}
	
	private func expect(_ sut: RemoteImageCommentLoader, toCompleteWith expectedResult: RemoteImageCommentLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load(imageId: "any") { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
				
			case let (.failure(receivedError), .failure(expectedError)):
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

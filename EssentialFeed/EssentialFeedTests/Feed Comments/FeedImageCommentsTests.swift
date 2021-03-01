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

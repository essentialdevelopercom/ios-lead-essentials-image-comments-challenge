//
//  RemoteImageCommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 17/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class RemoteImageCommentLoader {
	
	typealias Result = Swift.Result<Void, Swift.Error>
	
	enum Error: Swift.Error {
		case connectivity
	}
	
	let client: HTTPClient
	
	init(client: HTTPClient) {
		self.client = client
	}
	
	func load(from url: URL, completion: @escaping (Result) -> Void) {
		client.get(from: url) { _ in
			completion(.failure(Error.connectivity))
		}
	}
}

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let (sut, client) = makeSUT()
		let url = anyURL()
		
		sut.load(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestDataFromURLTwice() {
		let (sut, client) = makeSUT()
		let url = anyURL()
		
		sut.load(from: url) { _ in }
		sut.load(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversConnectivityErrorOnClientError() {
		let (sut, client) = makeSUT()
		let error = anyNSError()
		
		expect(sut: sut, toCompleteWith: .failure(RemoteImageCommentLoader.Error.connectivity)) {
			client.complete(with: error)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentLoader(client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func expect(sut: RemoteImageCommentLoader, toCompleteWith expectedResult: RemoteImageCommentLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let url = anyURL()
		let exp = expectation(description: "Wait for load completion")
		
		sut.load(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.failure(receivedError as RemoteImageCommentLoader.Error), .failure(expectedError as RemoteImageCommentLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
}

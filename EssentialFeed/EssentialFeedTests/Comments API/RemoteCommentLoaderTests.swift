//
//  RemoteCommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Eric Garlock on 2/28/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

private class RemoteCommentLoader {
	
	private let url: URL = URL(string: "http://any-url.com")!
	private let client: HTTPClient
	
	init(client: HTTPClient) {
		self.client = client
	}
	
	public func load(completion: @escaping (Error?) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .failure(error):
				completion(error)
			default:
				completion(nil)
			}
		}
	}
	
}

class RemoteCommentLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertEqual(client.requestedURLs.count, 0)
	}
	
	func test_load_requestsDataFromURL() {
		let (sut, client) = makeSUT()
		
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs.count, 1)
	}
	
	func test_load_requestsDataFromURLTwice() {
		let (sut, client) = makeSUT()
		
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs.count, 2)
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		let exp = expectation(description: "Wait for load completion")
		
		var receivedError: Error?
		sut.load { error in
			receivedError = error
			exp.fulfill()
		}
		
		client.complete(with: anyNSError())
		
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertNotNil(receivedError)
	}
	
	// MARK: - Helpers
	private func makeSUT() -> (sut: RemoteCommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteCommentLoader(client: client)
		trackForMemoryLeaks(sut)
		trackForMemoryLeaks(client)
		return (sut, client)
	}
	
	
}

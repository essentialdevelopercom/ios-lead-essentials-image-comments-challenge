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
	
	private let url: URL
	private let client: HTTPClient
	
	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	enum Error: Swift.Error, Equatable {
		case connectivity
		case invalidData
	}
	
	public func load(completion: @escaping (Error?) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .success:
				completion(.invalidData)
			case .failure:
				completion(.connectivity)
			}
		}
	}
	
}

class RemoteCommentLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertEqual(client.requestedURLs, [])
	}
	
	func test_load_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_load_requestsDataFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		let exp = expectation(description: "Wait for load completion")
		
		var receivedError: RemoteCommentLoader.Error?
		sut.load { error in
			receivedError = error
			exp.fulfill()
		}
		
		client.complete(with: anyNSError())
		
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError, .connectivity)
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let exp = expectation(description: "Wait for load completion")
		
		var receivedError: RemoteCommentLoader.Error?
		sut.load { error in
			receivedError = error
			exp.fulfill()
		}
		
		client.complete(withStatusCode: 199, data: anyData())
		
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError, .invalidData)
	}
	
	// MARK: - Helpers
	private func makeSUT(url: URL = anyURL()) -> (sut: RemoteCommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteCommentLoader(url: url, client: client)
		trackForMemoryLeaks(sut)
		trackForMemoryLeaks(client)
		return (sut, client)
	}
	
	
}

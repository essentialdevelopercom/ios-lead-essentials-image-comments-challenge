//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Bogdan Poplauschi on 27/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

final class RemoteCommentsLoader {
	private let url: URL
	private let client: HTTPClient
	
	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	func load(completion: @escaping (Result<[ImageComment], Error>) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .failure(error):
				completion(.failure(error))
				
			default:
				break
			}
		}
	}
}

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load { _ in }
		sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		let expectedError = NSError(domain: "Test", code: 0)
		
		let exp = expectation(description: "Wait for load completion")
		sut.load { result in
			switch result {
			case let .failure(receivedError):
				XCTAssertEqual(receivedError as NSError?, expectedError as NSError?)
				
			default:
				XCTFail("Expected failure, git \(result) instead.")
			}
			exp.fulfill()
		}
		
		client.complete(with: expectedError)
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteCommentsLoader(url: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
}

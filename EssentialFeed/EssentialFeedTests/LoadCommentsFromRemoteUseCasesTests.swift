//
//  LoadCommentsFromRemoteUseCasesTests.swift
//  EssentialFeediOSTests
//
//  Created by Robert Dates on 1/19/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct Comment: Equatable {
	
}

protocol CommentLoader {
	typealias Result = Swift.Result<[Comment], Error>
	func load(completion: @escaping (Result) -> Void)
}

class RemoteFeedCommentsLoader {
	
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	init(client: HTTPClient, url: URL) {
		self.url = url
		self.client = client
	}
	
	func load(completion: @escaping (CommentLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .failure(_):
				completion(.failure(Error.connectivity))
			default:
				break
			}
		}
	}
}


class LoadCommentsFromRemoteUseCasesTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURL() {
		
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load { _ in }
		sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		expect(sut, toCompleteWith: failure(RemoteFeedCommentsLoader.Error.connectivity)) {
			let clientError = anyNSError()
			client.complete(with: clientError)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedCommentsLoader, client: HTTPClientSpy) {
		let client =  HTTPClientSpy()
		let sut = RemoteFeedCommentsLoader(client: client, url: url)
		trackForMemoryLeaks(client)
		trackForMemoryLeaks(sut)
		
		return (sut, client)
	}
	
	private func failure(_ error: RemoteFeedCommentsLoader.Error) -> CommentLoader.Result {
		return .failure(error)
	}

	private func expect(_ sut: RemoteFeedCommentsLoader, toCompleteWith expectedResult: CommentLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		
		let exp = expectation(description: "Wait for load completion")
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
			case let (.failure(receivedError as RemoteFeedCommentsLoader.Error), .failure(expectedError as RemoteFeedCommentsLoader.Error)):
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

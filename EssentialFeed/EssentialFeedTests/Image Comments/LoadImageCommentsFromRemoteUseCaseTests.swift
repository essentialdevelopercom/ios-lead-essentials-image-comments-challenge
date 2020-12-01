//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Rakesh Ramamurthy on 01/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
	
	func test_init_doesNotPerformAnyURLRequest() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load(from: url) { _ in }

		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load(from: url) { _ in }
		sut.load(from: url) { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}

	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()

		let expectedError: RemoteImageCommentsLoader.Error = .invalidData
		let samples = [199, 300, 345, 400, 500]

		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(expectedError), when: {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			})
		}
	}

	func test_load_deliversConnectivityErrorOnClientConnectivityError() {
		let (sut, client) = makeSUT()

		let expectedError: RemoteImageCommentsLoader.Error = .connectivity

		expect(sut, toCompleteWith: .failure(expectedError), when: {
			client.complete(with: anyNSError())
		})
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: failure(.invalidData), when: {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 201, data: invalidJSON)
		})
	}

	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: .success([]), when: {
			let emptyListJSON = Data("{\"items\": [] }".utf8)
			client.complete(withStatusCode: 200, data: emptyListJSON)
		})
	}

	// MARK: - Helpers
	
	private func makeSUT(
		url _: URL = anyURL(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
		.failure(error)
	}

	private func expect(
		_ sut: RemoteImageCommentsLoader,
		toCompleteWith expectedResult: RemoteImageCommentsLoader.Result,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let exp = expectation(description: "Wait completion loader")
		let url = URL(string: "https://a-given-url.com")!

		sut.load(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedComments), .success(expectedComments)):
				XCTAssertEqual(receivedComments, expectedComments, file: file, line: line)
			case let (.failure(receivedError), .failure(expectedError)):
				XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
			default:
				XCTFail("Expected failure, got \(receivedResult) instead.", file: file, line: line)
			}
			exp.fulfill()
		}

		action()
		wait(for: [exp], timeout: 1.0)
	}
}

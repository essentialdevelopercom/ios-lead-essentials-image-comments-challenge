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
		case invalidData
	}
	
	let client: HTTPClient
	
	init(client: HTTPClient) {
		self.client = client
	}
	
	func load(from url: URL, completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((_, response)):
				guard (200..<300).contains(response.statusCode) else {
					return completion(.failure(Error.invalidData))
				}
				completion(.failure(Error.invalidData))
			case .failure:
				completion(.failure(Error.connectivity))
			}
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
		
		expect(sut: sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: error)
		})
	}
	
	func test_load_deliversInvalidDataErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()
		let samples = [199, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}
	
	// MARK: - Helpers
	
	private func failure(_ error: RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result {
		return .failure(error)
	}
	
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
			case (.success, .success):
				break
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

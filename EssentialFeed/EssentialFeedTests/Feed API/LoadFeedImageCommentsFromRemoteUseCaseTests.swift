//
//  LoadFeedImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mario Alberto Barragán Espinosa on 04/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedImageCommentsFromRemoteUseCaseTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_loadImageCommentDataFromURL_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.loadImageCommentData(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadImageCommentDataFromURL_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.loadImageCommentData(from: url) { _ in }
		sut.loadImageCommentData(from: url) { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_loadImageCommentDataFromURL_deliversConnectivityErrorOnClientError() {
		let (sut, client) = makeSUT()
		let clientError = anyNSError()

		expect(sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: clientError)
		})
	}
	
	func test_loadImageCommentDataFromUR_deliversInvalidDataErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()

		let samples = [199, 201, 300, 400, 500]

		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			})
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageCommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageCommentLoader(client: client)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func failure(_ error: RemoteFeedImageCommentLoader.Error) -> FeedImageCommentLoader.Result {
		return .failure(error)
	}
	
	private func expect(_ sut: RemoteFeedImageCommentLoader, toCompleteWith expectedResult: FeedImageCommentLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let url = URL(string: "https://a-given-url.com")!
		let exp = expectation(description: "Wait for load completion")

		sut.loadImageCommentData(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)
				
			case let (.failure(receivedError as RemoteFeedImageCommentLoader.Error), .failure(expectedError as RemoteFeedImageCommentLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)

			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
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

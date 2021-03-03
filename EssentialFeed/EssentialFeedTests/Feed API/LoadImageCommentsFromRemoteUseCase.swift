//
//  LoadImageCommentsFromRemoteUseCase.swift
//  EssentialFeedTests
//
//  Created by Adrian Szymanowski on 02/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCase: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_loadImageComments_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT()
		
		_ = sut.loadImageComments(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadImageCommentsTwice_requestsImageCommentsTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT()
		
		_ = sut.loadImageComments(from: url) { _ in }
		_ = sut.loadImageComments(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_loadImageComments_deliversConnectivityErrorOnClientError() {
		let (sut, client) = makeSUT()
		let clientError = anyNSError()
		
		expect(sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: clientError)
		})
	}
	
	func test_loadImageComments_deliversInvalidDataErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199, 201, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			})
		}
	}
	
	func test_loadImageComments_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.invalidData), when: {
			let emptyData = Data()
			client.complete(withStatusCode: 200, data: emptyData)
		})
	}
	
	func test_loadImageComments_deliversReceivedNonEmptyDataOn200HTTPResponse() {
		let (sut, client) = makeSUT()
		let nonEmptyData = Data("non-empty data".utf8)
		
		expect(sut, toCompleteWith: .success(nonEmptyData), when: {
			client.complete(withStatusCode: 200, data: nonEmptyData)
		})
	}
	
	func test_cancelLoadImageComments_cancelsClientURLRequest() {
		let (sut, client) = makeSUT()
		let url = URL(string: "https://a-given-url.com")!
		
		let task = sut.loadImageComments(from: url) { _ in }
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL requests until task is cancelled")
		
		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
	}
	
	func test_loadImageComments_doesNotDeliverResultAfterCancellingTask() {
		let (sut, client) = makeSUT()
		let nonEmptyData = Data("non-empty data".utf8)
		
		var received = [ImageCommentsLoader.Result]()
		let task = sut.loadImageComments(from: anyURL()) { received.append($0) }
		task.cancel()
		
		client.complete(withStatusCode: 404, data: anyData())
		client.complete(withStatusCode: 200, data: nonEmptyData)
		client.complete(with: anyNSError())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
	}
	
	func test_loadImageComments_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(client: client)
		
		var capturedResults = [ImageCommentsLoader.Result]()
		_ = sut?.loadImageComments(from: anyURL()) { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: anyData())
		
		XCTAssertTrue(capturedResults.isEmpty)
	}

	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, client)
	}
	
	private func failure(_ error: RemoteImageCommentsLoader.Error) -> ImageCommentsLoader.Result {
		.failure(error)
	}
	
	private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for load comments completion")
		
		_ = sut.loadImageComments(from: anyURL()) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedData), .success(expectedData)):
				XCTAssertEqual(receivedData, expectedData, file: file, line: line)
			
			case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			default:
				XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
	
}

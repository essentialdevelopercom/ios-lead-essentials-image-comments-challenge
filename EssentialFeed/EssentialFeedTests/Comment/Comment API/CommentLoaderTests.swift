//
//  CommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Khoi Nguyen on 24/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct Comment {
	
}

class RemoteCommentLoader {
	
	private let url: URL
	private let client: HTTPClient
	
	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	typealias Result = Swift.Result<[Comment], Error>
	
	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((_, response)) where response.statusCode != 200:
				completion(.failure(.invalidData))
			case .failure:
				completion(.failure(.connectivity))
			default: break
			}
		}
	}
}

class CommentLoaderTests: XCTestCase {
	func test_init_doesNotRequestComment() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty, "Expected no requested url upon creation")
	}
	
	func test_load_requestsFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(.connectivity)) {
			client.completeWith(error: anyNSError())
		}
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let codeSamples = [199, 201, 303, 404, 500]
		
		codeSamples.enumerated().forEach { (index, code) in
			expect(sut, toCompleteWith: .failure(.invalidData)) {
				let non200HTTPResponse = hTTPResponse(code: code)
				client.completeWith(data: anyData(), response: non200HTTPResponse, at: index)
			}
		}
	}
	
	// MARK: - Helpers
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteCommentLoader, client: ClientSpy) {
		let client = ClientSpy()
		let sut = RemoteCommentLoader(url: url, client: client)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		
		return (sut, client)
	}
	
	private func expect(_ sut: RemoteCommentLoader, toCompleteWith expectedResult: RemoteCommentLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		
		let exp = expectation(description: "Wait for load completion")
		sut.load() { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.failure(receivedError), .failure(expectedError)):
				XCTAssertEqual(receivedError, expectedError)
			default: break
			}
			exp.fulfill()
		}
		action()
		wait(for: [exp], timeout: 1.0)
	}
	
	class ClientSpy: HTTPClient {
		
		var requestedURLs: [URL] {
			messages.map { $0.url }
		}
		var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
		
		private class Task: HTTPClientTask {
			func cancel() {
				
			}
		}
		
		func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
			messages.append((url, completion))
			return Task()
		}
		
		func completeWith(error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
		
		func completeWith(data: Data, response: HTTPURLResponse, at index: Int = 0) {
			messages[index].completion(.success((data, response)))
		}
	}
	
	private func hTTPResponse(code: Int) -> HTTPURLResponse {
		return HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!
	}
}

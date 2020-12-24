//
//  CommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Khoi Nguyen on 24/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct Comment: Equatable {
	
}

class RemoteCommentLoader {
	
	private let url: URL
	private let client: HTTPClient
	
	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	typealias Result = Swift.Result<[Comment], Error>
	
	enum Error: Swift.Error, Equatable {
		case connectivity
	}
	
	func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .failure:
				completion(.failure(.connectivity))
			default:
				break
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
		
		var receivedResult: RemoteCommentLoader.Result?
		sut.load() { receivedResult = $0 }
		client.completeWith(error: anyNSError())
		
		XCTAssertEqual(receivedResult, .failure(.connectivity))
	}
	
	// MARK: - Helpers
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteCommentLoader, client: ClientSpy) {
		let client = ClientSpy()
		let sut = RemoteCommentLoader(url: url, client: client)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		
		return (sut, client)
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
	}
}

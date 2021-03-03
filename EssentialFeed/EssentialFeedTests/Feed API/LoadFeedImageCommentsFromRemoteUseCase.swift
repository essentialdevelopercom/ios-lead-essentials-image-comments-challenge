//
//  LoadFeedImageCommentsFromRemoteUseCase.swift
//  EssentialFeedTests
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedImageCommentsLoader {
	let client: HTTPClient
	let url: URL
	
	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}
	
	func load(completion: @escaping (Error) -> Void) {
		client.get(from: url, completion: { result in
			switch result {
			case .success(_):
				completion(.invalidData)
			case .failure(_):
				completion(.connectivity)
			}
		})
	}
}

class LoadFeedImageCommentsFromRemoteUseCase: XCTestCase {
	
	func test_init_doesNotRequestsDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "http://a-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "http://a-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		var capturedErrors = [RemoteFeedImageCommentsLoader
								.Error]()
		sut.load() { capturedErrors.append($0) }
		let clientError = NSError(domain: "Test", code: 0)
		client.complete(with: clientError)
		
		XCTAssertEqual(capturedErrors, [.connectivity])
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199, 201, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			var capturedErrors = [RemoteFeedImageCommentsLoader.Error]()
			
			sut.load() { capturedErrors.append($0) }
			client.complete(withStatusCode: code, data: anyData(), at: index)
			
			XCTAssertEqual(capturedErrors, [.invalidData])
		}
	}
	
	// MARK - Helpers
	
	func makeSUT(url: URL = URL(string: "https://a-default-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedImageCommentsLoader, HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageCommentsLoader(client: client, url: url)
		return (sut, client)
	}
}

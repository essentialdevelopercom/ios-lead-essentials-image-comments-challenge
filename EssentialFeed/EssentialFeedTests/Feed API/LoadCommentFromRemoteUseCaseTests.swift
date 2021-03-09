//
//  LoadCommentFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Mayorga on 3/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import Foundation
import EssentialFeed

class RemoteCommentLoader {
	let url: URL
	let httpClient: HTTPClient
	
	typealias Result = Swift.Result<[Comment], Error>
	
	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	init(url: URL, client: HTTPClient) {
		self.url = url
		self.httpClient = client
	}
	
	func load(completion: @escaping (Result) -> Void) {
		httpClient.get(from: url) { (result) in
			switch result {
			case .failure:
				completion(.failure(.connectivity))
				
			case let .success((data, response)):
				if response.statusCode != 200 {
					completion(.failure(.invalidData))
				} else {
					completion(.failure(.invalidData))
				}
			}
		}
	}
}

class LoadCommentFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotRequestDataOnInit() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestDataFromURL() {
		let url = URL(string: "https://another-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load { (_) in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestDataFromURLTwice() {
		let url = URL(string: "https://another-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load { (_) in }
		sut.load { (_) in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_requestDataFromRemoteDeliversClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, client: client, expectedResult: .failure(.connectivity), action: {
			client.complete(with: RemoteCommentLoader.Error.connectivity)
		})
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		let statusCodes = [199, 201, 300, 400, 500]
		
		statusCodes.enumerated().forEach { index, code in
			expect(sut, client: client, expectedResult: .failure(.invalidData)) {
				client.complete(withStatusCode: code, data: Data.init(), at: index)
			}
		}
	}
	
	func test_load_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
		let (sut, client) = makeSUT()
		
		expect(sut, client: client, expectedResult: .failure(.invalidData)) {
			client.complete(withStatusCode: 200, data: Data())
		}
	}
	
	// MARK: - Helpers
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteCommentLoader, spy: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteCommentLoader(url: url, client: client)
		
		return (sut, client)
	}

	private func expect(_ sut: RemoteCommentLoader, client: HTTPClientSpy, expectedResult: RemoteCommentLoader.Result, action: () -> Void) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load { (receivedResult) in
			XCTAssertEqual(receivedResult, expectedResult)
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
}

//
//  FeedImageCommentsTests.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct FeedComment: Hashable {
	let id: UUID
	let message: String
	let createdAt: String
	let author: FeedCommentAuthor
}

struct FeedCommentAuthor: Hashable {
	let username: String
}

class RemoteImageFeedCommentLoader {
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	typealias Result = Swift.Result<[FeedComment], Error>
	
	private let baseUrl: URL
	private let client: HTTPClient
	
	init(baseUrl: URL, client: HTTPClient) {
		self.baseUrl = baseUrl
		self.client = client
	}
	
	func load(imageId: String, completion: @escaping (Result) -> Void) {
		client.get(from: baseUrl, completion: { result in
			switch result {
			case .success: break
			case .failure:
				completion(.failure(.connectivity))
			}
		})
	}
	
}

final class FeedImageCommentsTests: XCTestCase {

	func test_init_doesNotRequestDataFromUrl() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
		let (loader, client) = makeSUT(url: url)

		loader.load(imageId: "any", completion: { _ in })

		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: failure(.connectivity), when: {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		})
	}
	
	private func failure(_ error: RemoteImageFeedCommentLoader.Error) -> RemoteImageFeedCommentLoader.Result {
		return .failure(error)
	}
	
	private func makeSUT(url: URL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!) -> (RemoteImageFeedCommentLoader, HTTPClientSpy) {
		let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
		let client = HTTPClientSpy()
		let loader = RemoteImageFeedCommentLoader(baseUrl: url, client: client)

		return (loader, client)
	}
	
	private func expect(_ sut: RemoteImageFeedCommentLoader, toCompleteWith expectedResult: RemoteImageFeedCommentLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load(imageId: "any") { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
				
			case let (.failure(receivedError), .failure(expectedError)):
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

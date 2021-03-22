//
//  LoadImageCommentsDataFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sebastian Vidrea on 19.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteImageCommentsLoader {
	private let url: URL
	private let client: HTTPClient

	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	func load(completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200 else {
					completion(.failure(NSError(domain: "invalid status code", code: 0)))
					return
				}
				completion(.success((data, response)))

			case let .failure(error):
				completion(.failure(error))
			}
		}
	}
}

class LoadImageCommentsDataFromRemoteUseCaseTests: XCTestCase {

	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load { _ in}

		XCTAssertEqual(client.requestedURLs, [url])
	}

	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load { _ in }
		sut.load { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}

	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()

		let clientError = NSError(domain: "Test", code: 0)

		let exp = expectation(description: "Wait for load completion")
		sut.load { result in
			switch result {
			case let .failure(error as NSError):
				XCTAssertEqual(error.code, clientError.code)

			default:
				XCTFail("Expected result \(clientError) got \(result) instead")
			}

			exp.fulfill()
		}
		client.complete(with: clientError)

		wait(for: [exp], timeout: 1.0)
	}

	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()

		let clientError = NSError(domain: "Test", code: 0)
		let statusCode = 201

		let exp = expectation(description: "Wait for load completion")
		sut.load { result in
			switch result {
			case let .failure(error as NSError):
				XCTAssertEqual(error.code, clientError.code)

			default:
				XCTFail("Expected result \(clientError) got \(result) instead")
			}

			exp.fulfill()
		}
		client.complete(withStatusCode: statusCode, data: "".data(using: .utf8)!)

		wait(for: [exp], timeout: 1.0)
	}

	// MARK: - Helpers
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(url: url, client: client)
		return (sut, client)
	}
}

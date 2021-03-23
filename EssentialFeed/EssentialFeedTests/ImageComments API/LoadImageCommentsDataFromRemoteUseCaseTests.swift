//
//  LoadImageCommentsDataFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sebastian Vidrea on 19.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct ImageComment: Equatable { }

class RemoteImageCommentsLoader {
	private let url: URL
	private let client: HTTPClient

	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	typealias Result = Swift.Result<[ImageComment], Error>

	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200 else {
					completion(.failure(Error.invalidData))
					return
				}
				if let _ = try? JSONSerialization.jsonObject(with: data) {
					completion(.success([]))
				} else {
					completion(.failure(.invalidData))
				}

			case .failure:
				completion(.failure(Error.connectivity))
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

		sut.load { _ in }

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

		expect(sut, toCompleteWith: .failure(RemoteImageCommentsLoader.Error.connectivity)) {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		}
	}

	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()

		let statusCodes = [199, 201, 300, 400, 500]

		statusCodes.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(.invalidData)) {
				client.complete(withStatusCode: code, data: "".data(using: .utf8)!, at: index)
			}
		}
	}

	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()

		let invalidJSON = Data("invalid json".utf8)

		expect(sut, toCompleteWith: .failure(.invalidData)) {
			client.complete(withStatusCode: 200, data: invalidJSON)
		}
	}

	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()

		let emptyListJSON = makeItemsJSON([])

		expect(sut, toCompleteWith: .success([])) {
			client.complete(withStatusCode: 200, data: emptyListJSON)
		}
	}

	// MARK: - Helpers
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(url: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}

	private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")

		sut.load { receivedResult in
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

	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
}

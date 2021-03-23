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

	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	func load(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
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

		let exp = expectation(description: "Wait for load completion")
		sut.load { result in
			switch result {
			case let .failure(error):
				XCTAssertEqual(error, .connectivity)

			default:
				XCTFail("Expected result \(RemoteImageCommentsLoader.Error.connectivity) got \(result) instead")
			}

			exp.fulfill()
		}
		client.complete(with: RemoteImageCommentsLoader.Error.connectivity)

		wait(for: [exp], timeout: 1.0)
	}

	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()


		let statusCodes = [199, 201, 300, 400, 500]

		let exp = expectation(description: "Wait for load completion")
		exp.expectedFulfillmentCount = statusCodes.count
		statusCodes.enumerated().forEach { index, code in
			sut.load { result in
				switch result {
				case let .failure(error):
					XCTAssertEqual(error, .invalidData)

				default:
					XCTFail("Expected result \(RemoteImageCommentsLoader.Error.invalidData) got \(result) instead")
				}

				exp.fulfill()
			}
			client.complete(withStatusCode: code, data: "".data(using: .utf8)!)
		}

		wait(for: [exp], timeout: 1.0)
	}

	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()

		let invalidJSON = Data("invalid json".utf8)

		let exp = expectation(description: "Wait for load completion")
		sut.load { result in
			switch result {
			case let .failure(error):
				XCTAssertEqual(error, .invalidData)

			default:
				XCTFail("Expected result \(RemoteImageCommentsLoader.Error.invalidData) got \(result) instead")
			}

			exp.fulfill()
		}
		client.complete(withStatusCode: 200, data: invalidJSON)

		wait(for: [exp], timeout: 1.0)
	}

	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()

		let emptyListJSON = makeItemsJSON([])

		let exp = expectation(description: "Wait for load completion")
		sut.load { result in
			switch result {
			case let .success(items):
				XCTAssertTrue(items.isEmpty)

			default:
				XCTFail("Expected result \(RemoteImageCommentsLoader.Error.invalidData) got \(result) instead")
			}

			exp.fulfill()
		}

		client.complete(withStatusCode: 200, data: emptyListJSON)
		wait(for: [exp], timeout: 1.0)
	}

	// MARK: - Helpers
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(url: url, client: client)
		trackForMemoryLeaks(sut)
		trackForMemoryLeaks(client)
		return (sut, client)
	}

	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
}

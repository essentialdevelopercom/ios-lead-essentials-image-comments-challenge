//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Cronay on 13.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct Root: Decodable {
	let items: [ImageComment]
}

struct ImageComment: Equatable, Decodable {

}

class RemoteImageCommentsLoader {
	private let client: HTTPClient
	private let url: URL

	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}

	func load(completion: @escaping (Result<[ImageComment], Swift.Error>) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))

			case let .success((data, response)):
				if !(200 ... 299 ~= response.statusCode) {
					completion(.failure(Error.invalidData))
				} else {
					let jsonDecoder = JSONDecoder()
					if let _ = try? jsonDecoder.decode(Root.self, from: data) {
						completion(.success([]))
					} else {
						completion(.failure(Error.invalidData))
					}
				}
			}
		}
	}
}

class RemoteImageCommentsLoaderTests: XCTestCase {

	func test_init_doesNotRequestFromURL() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsFromURL() {
		let commentsURL = URL(string: "http://comments-url.com")!
		let (sut, client) = makeSUT(url: commentsURL)

		sut.load() { _ in }

		XCTAssertEqual(client.requestedURLs, [commentsURL])
	}

	func test_loadTwice_requestsFromURLTwice() {
		let commentsURL = URL(string: "http://comments-url.com")!
		let (sut, client) = makeSUT(url: commentsURL)

		sut.load() { _ in }
		sut.load() { _ in }

		XCTAssertEqual(client.requestedURLs, [commentsURL, commentsURL])
	}

	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: .failure(RemoteImageCommentsLoader.Error.connectivity), when: {
			client.complete(with: anyNSError())
		})
	}

	func test_load_deliversErrorOnHTTPResponseWithStatusCodeOutsideOf2XXRange() {
		let (sut, client) = makeSUT()

		let nonAcceptedCodes = [100, 199, 301, 404, 503]

		nonAcceptedCodes.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(RemoteImageCommentsLoader.Error.invalidData), when: {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			})
		}
	}

	func test_load_deliversErrorOn200HTTPResponseWithInvalidJsonData() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: .failure(RemoteImageCommentsLoader.Error.invalidData), when: {
			let invalidJsonData = Data("invalid data".utf8)
			client.complete(withStatusCode: 200, data: invalidJsonData)
		})
	}

	func test_load_deliversNoCommentItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: .success([]), when: {
			client.complete(withStatusCode: 200, data: try! JSONSerialization.data(withJSONObject: ["items": []]))
		})
	}

	// MARK: - Helpers

	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client, url: url)
		trackForMemoryLeaks(client)
		trackForMemoryLeaks(sut)
		return (sut, client)
	}

	private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: Result<[ImageComment], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")

		sut.load { receivedResult in
			switch (expectedResult, receivedResult) {
			case let (.success(expectedComments),
					  .success(receivedComments)):
				XCTAssertEqual(expectedComments, receivedComments, file: file, line: line)

			case let (.failure(expectedError as RemoteImageCommentsLoader.Error),
					  .failure(receivedError as RemoteImageCommentsLoader.Error)):
				XCTAssertEqual(expectedError, receivedError, file: file, line: line)

			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}

			exp.fulfill()
		}

		action()

		wait(for: [exp], timeout: 1.0)
	}
}

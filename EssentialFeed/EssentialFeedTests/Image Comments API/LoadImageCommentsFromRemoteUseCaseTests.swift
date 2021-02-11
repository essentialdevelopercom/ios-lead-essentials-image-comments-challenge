//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 08/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

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
		let expectedError = RemoteImageCommentsLoader.Error.connectivity

		expect(
			sut: sut,
			toCompleteWith: failure(expectedError),
			when: {
				client.complete(with: expectedError)
			}
		)
	}

	func test_load_deliversErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()

		let samples = [199, 300, 400, 401, 500]

		samples.enumerated().forEach { index, code in
			expect(
				sut: sut,
				toCompleteWith: failure(.invalidData),
				when: {
					client.complete(
						withStatusCode: code,
						data: anyData(),
						at: index
					)
				}
			)
		}
	}

	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()

		expect(
			sut: sut,
			toCompleteWith: failure(.invalidData),
			when: {
				let invalidJSON = Data("invalid json".utf8)
				client.complete(
					withStatusCode: 200,
					data: invalidJSON
				)
			}
		)
	}

	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()

		expect(
			sut: sut,
			toCompleteWith: .success([]),
			when: {
				let emptyListJSON = makeItemsJSON([])
				client.complete(withStatusCode: 200, data: emptyListJSON)
			}
		)
	}

	func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()

		let item1 = makeItem(
			message: "a message",
			createdAt: (
				Date(timeIntervalSince1970: 1610000000),
				"2021-01-07T06:13:20+00:00"
			),
			username: "a username"
		)

		let item2 = makeItem(
			message: "another message",
			createdAt: (
				Date(timeIntervalSince1970: 1612907740),
				"2021-02-09T21:55:40+00:00"
			),
			username: "another username"
		)

		let items = [item1.model, item2.model]

		expect(
			sut: sut,
			toCompleteWith: .success(items),
			when: {
				let json = makeItemsJSON([item1.json, item2.json])
				client.complete(withStatusCode: 200, data: json)
			}
		)
	}

	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let url = URL(string: "http://any-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)

		var capturedResults = [RemoteImageCommentsLoader.Result]()
		sut?.load { capturedResults.append($0) }

		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))

		XCTAssertTrue(capturedResults.isEmpty)
	}

	// MARK: - Helpers

	private func makeSUT(
		url: URL = anyURL(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(url: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}

	private func expect(
		sut: RemoteImageCommentsLoader,
		toCompleteWith expectedResult: RemoteImageCommentsLoader.Result,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let exp = expectation(description: "Wait completion loader")

		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

			case let (
				.failure(receivedError as RemoteImageCommentsLoader.Error),
				.failure(expectedError as RemoteImageCommentsLoader.Error)
			):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			default:
				XCTFail(
					"Expected result \(expectedResult) but got \(receivedResult) instead",
					file: file,
					line: line
				)
			}

			exp.fulfill()
		}

		action()

		wait(for: [exp], timeout: 1.0)
	}

	private func makeItem(
		id: UUID = UUID(),
		message: String,
		createdAt: (date: Date, iso8601String: String),
		username: String
	) -> (model: ImageComment, json: [String: Any]) {
		let item = ImageComment(
			id: id,
			message: message,
			createdAt: createdAt.date,
			username: username
		)

		let json = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.iso8601String,
			"author": [
				"username": username
			]
		].compactMapValues { $0 }

		return (item, json)
	}

	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}

	private func failure(
		_ error: RemoteImageCommentsLoader.Error
	) -> RemoteImageCommentsLoader.Result {
		.failure(error)
	}
}

//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 08/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

final class RemoteLoaderTests: XCTestCase {

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
		let expectedError = RemoteLoader<String>.Error.connectivity

		expect(
			sut: sut,
			toCompleteWith: failure(expectedError),
			when: {
				client.complete(with: expectedError)
			}
		)
	}

	func test_load_deliversErrorOnMapperError() {
		let (sut, client) = makeSUT(mapper: { _, _ in
			throw anyNSError()
		})
		
		expect(
			sut: sut,
			toCompleteWith: failure(.invalidData),
			when: {
				client.complete(
					withStatusCode: 200,
					data: anyData()
				)
			}
		)
	}

	func test_load_deliversMappedResource() {
		let resource = "a resource"
		let (sut, client) = makeSUT(mapper: { data, _ in
			String(data: data, encoding: .utf8)!
		})

		expect(
			sut: sut,
			toCompleteWith: .success(resource),
			when: {
				client.complete(
					withStatusCode: 200,
					data: Data(resource.utf8)
				)
			}
		)
	}

	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let url = URL(string: "http://any-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteLoader<String>? = RemoteLoader(url: url, client: client, mapper: { _, _ in "mapped" })

		var capturedResults = [RemoteLoader<String>.Result]()
		sut?.load { capturedResults.append($0) }

		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))

		XCTAssertTrue(capturedResults.isEmpty)
	}

	// MARK: - Helpers

	private func makeSUT(
		url: URL = anyURL(),
		mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "mapped" },
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteLoader(url: url, client: client, mapper: mapper)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}

	private func expect(
		sut: RemoteLoader<String>,
		toCompleteWith expectedResult: RemoteLoader<String>.Result,
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
				.failure(receivedError as RemoteLoader<String>.Error),
				.failure(expectedError as RemoteLoader<String>.Error)
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
		_ error: RemoteLoader<String>.Error
	) -> RemoteLoader<String>.Result {
		.failure(error)
	}
}

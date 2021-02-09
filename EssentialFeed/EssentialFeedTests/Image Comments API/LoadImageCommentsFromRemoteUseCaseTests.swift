//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 08/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

public struct ImageComment: Equatable {
	public let id: UUID
	public let message: String
	public let createdAt: Date
	public let username: String

	public init(
		id: UUID,
		message: String,
		createdAt: Date,
		username: String
	) {
		self.id = id
		self.message = message
		self.createdAt = createdAt
		self.username = username
	}
}

public enum ImageCommentsMapper {
	private struct Root: Decodable {

		private struct Item: Decodable {
			let id: UUID
			let message: String
			let created_at: Date
			let author: Author
		}

		private struct Author: Decodable {
			let username: String
		}

		private let items: [Item]

		var comments: [ImageComment] {
			items.map {
				ImageComment(
					id: $0.id,
					message: $0.message,
					createdAt: $0.created_at,
					username: $0.author.username
				)
			}
		}
	}

	static func map(
		_ data: Data,
		from response: HTTPURLResponse
	) throws -> [ImageComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601

		guard isOK(response), let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}

		return root.comments
	}

	private static func isOK(_ response: HTTPURLResponse) -> Bool {
		(200...299).contains(response.statusCode)
	}
}

public final class RemoteImageCommentsLoader {

	public typealias Result = Swift.Result<[ImageComment], Error>

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	private let client: HTTPClient

	public init(client: HTTPClient) {
		self.client = client
	}

	@discardableResult
	public func load(
		from url: URL,
		completion: @escaping (Result) -> Void
	) -> HTTPClientTask {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				guard let comments = try? ImageCommentsMapper.map(data, from: response) else {
					return completion(.failure(.invalidData))
				}

				completion(.success(comments))
			case .failure:
				completion(.failure(.connectivity))
			}
		}
	}
}

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load(from: url) { _ in }

		XCTAssertEqual(client.requestedURLs, [url])
	}

	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load(from: url) { _ in }
		sut.load(from: url) { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}

	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		let expectedError = RemoteImageCommentsLoader.Error.connectivity

		expect(
			sut: sut,
			toCompleteWith: .failure(expectedError),
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
				toCompleteWith: .failure(.invalidData),
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
			toCompleteWith: .failure(.invalidData),
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
		var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(client: client)

		var capturedResults = [RemoteImageCommentsLoader.Result]()
		sut?.load(from: url) { capturedResults.append($0) }

		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))

		XCTAssertTrue(capturedResults.isEmpty)
	}

	func test_cancelLoadComments_cancelsClientURLRequest() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: anyURL())

		let task = sut.load(from: url) { _ in }

		XCTAssertTrue(
			client.cancelledURLs.isEmpty,
			"Expected no cancelled URL request until task is cancelled"
		)

		task.cancel()

		XCTAssertEqual(
			client.cancelledURLs,
			[url],
			"Expected cancelled URL request after task is cancelled"
		)
	}

	// MARK: - Helpers

	private func makeSUT(
		url: URL = anyURL(),
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client)
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
		let url = URL(string: "https://a-given-url.com")!

		sut.load(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

			case let (.failure(receivedError), .failure(expectedError)):
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
}

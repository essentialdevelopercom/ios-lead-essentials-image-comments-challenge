//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Cronay on 13.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

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

	typealias Result = Swift.Result<[ImageComment], Swift.Error>

	func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))

			case let .success((data, response)):
				completion(RemoteImageCommentsLoader.map(data, from: response))
			}
		}
	}

	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		Result {
			try RemoteImageCommentMapper.map(data, from: response).mapToModels()
		}
	}
}

class RemoteImageCommentMapper {

	static let jsonDecoder: JSONDecoder = {
		let jsonDecoder = JSONDecoder()
		jsonDecoder.dateDecodingStrategy = .iso8601
		return jsonDecoder
	}()

	private struct Root: Decodable {
		let items: [RemoteImageCommentsItem]
	}

	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteImageCommentsItem] {
		if response.isInSuccessRange, let root = try? jsonDecoder.decode(Root.self, from: data) {
			return root.items
		} else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}
	}
}

struct RemoteImageCommentsItem: Decodable {
	let id: UUID
	let message: String
	let created_at: Date
	let author: RemoteImageCommentAuthorItem
}

struct RemoteImageCommentAuthorItem: Decodable {
	let username: String
}


private extension Array where Element == RemoteImageCommentsItem {
	func mapToModels() -> [ImageComment] {
		return map {
			.init(
				id: $0.id,
				message: $0.message,
				createdAt: $0.created_at,
				author: ImageCommentAuthor(username: $0.author.username)
			)
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

	func test_load_deliversItemOn200HTTPResponseWithNonEmtpyJSONList() {
		let (sut, client) = makeSUT()
		let image0 = makeItem(
			id: UUID(),
			message: "some message",
			createdAt: (Date(timeIntervalSince1970: 1222222222), "2008-09-24T02:10:22+00:00"),
			author: "some user"
		)
		let image1 = makeItem(
			id: UUID(),
			message: "another message",
			createdAt: (Date(timeIntervalSince1970: 1333333333), "2012-04-02T02:22:13+00:00"),
			author: "some other user"
		)

		expect(sut, toCompleteWith: .success([image0.model, image1.model]), when: {
			let data = makeItemJSON(with: [image0.json, image1.json])
			client.complete(withStatusCode: 200, data: data)
		})
	}

	// MARK: - Helpers

	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client, url: url)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, client)
	}

	private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601: String), author: String) -> (model: ImageComment, json: [String: Any]) {
		let model = ImageComment(
			id: id,
			message: message,
			createdAt: createdAt.date,
			author: ImageCommentAuthor(username: author))

		let json: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.iso8601,
			"author": [
				"username": author
			]
		]
		return (model, json)
	}

	private func makeItemJSON(with items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
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

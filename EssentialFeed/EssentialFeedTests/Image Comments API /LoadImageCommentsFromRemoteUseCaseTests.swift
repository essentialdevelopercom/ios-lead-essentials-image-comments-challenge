//
//  RemoteImageCommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 17/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class RemoteImageCommentLoader {
	
	typealias Result = Swift.Result<[ImageComment], Swift.Error>
	
	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	private struct Root: Decodable {
		let items: [RemoteImageComment]
	}
	
	private struct RemoteImageComment: Decodable {
		struct Author: Decodable {
			let username: String
		}
		
		let id: UUID
		let message: String
		let createdAt: Date
		let author: Author
		
		var imageComment: ImageComment {
			ImageComment(id: id, message: message, creationDate: createdAt, author: author.username)
		}
	}
	
	let client: HTTPClient
	
	init(client: HTTPClient) {
		self.client = client
	}
	
	func load(from url: URL, completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				guard (200..<300).contains(response.statusCode) else {
					return completion(.failure(Error.invalidData))
				}
				
				let jsonDecoder = JSONDecoder()
				jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
				jsonDecoder.dateDecodingStrategy = .iso8601
				
				if let root = try? jsonDecoder.decode(Root.self, from: data) {
					completion(.success(root.items.map(\.imageComment)))
				} else {
					completion(.failure(Error.invalidData))
				}
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let (sut, client) = makeSUT()
		let url = anyURL()
		
		sut.load(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestDataFromURLTwice() {
		let (sut, client) = makeSUT()
		let url = anyURL()
		
		sut.load(from: url) { _ in }
		sut.load(from: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversConnectivityErrorOnClientError() {
		let (sut, client) = makeSUT()
		let error = anyNSError()
		
		expect(sut: sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: error)
		})
	}
	
	func test_load_deliversInvalidDataErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()
		let samples = [199, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}
	
	func test_load_deliversNoCommentsOn200HTTPResponseWithEmptyList() {
		let (sut, client) = makeSUT()
		
		expect(sut: sut, toCompleteWith: .success([]), when: {
			let emptyListJSON = makeCommentsJSON([])
			client.complete(withStatusCode: 200, data: emptyListJSON)
		})
	}
	
	func test_load_deliversCommentsOn200HTTPResponseWithCommentsList() {
		let (sut, client) = makeSUT()
		
		let comment1 = makeComment(
			id: UUID(),
			message: "a message",
			creationDate: (timestamp: 1_589_973_899, iso8601Representation: "2020-05-20T11:24:59+0000"),
			author: "a username"
		)
		let comment2 = makeComment(
			id: UUID(),
			message: "another message",
			creationDate: (timestamp: 1_589_898_233, iso8601Representation: "2020-05-19T14:23:53+0000"),
			author: "another username"
		)
		
		expect(sut: sut, toCompleteWith: .success([comment1.model, comment2.model]), when: {
			let json = makeCommentsJSON([comment1.json, comment2.json])
			client.complete(withStatusCode: 200, data: json)
		})
	}
	
	// MARK: - Helpers
	
	private func failure(_ error: RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result {
		return .failure(error)
	}
	
	private func makeComment(
		id: UUID,
		message: String,
		creationDate: (timestamp: TimeInterval, iso8601Representation: String),
		author: String
	) -> (model: ImageComment, json: [String: Any]) {
		let comment = ImageComment(id: id, message: message, creationDate: Date(timeIntervalSince1970: creationDate.timestamp), author: author)
		let json: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": creationDate.iso8601Representation,
			"author": [
				"username": author
			]
		]
		return (comment, json)
	}
	
	private func makeCommentsJSON(_ comments: [[String: Any]]) -> Data {
		let json = ["items": comments]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentLoader(client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func expect(sut: RemoteImageCommentLoader, toCompleteWith expectedResult: RemoteImageCommentLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let url = anyURL()
		let exp = expectation(description: "Wait for load completion")
		
		sut.load(from: url) { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedComments), .success(expectedComments)):
				XCTAssertEqual(receivedComments, expectedComments, file: file, line: line)
			case let (.failure(receivedError as RemoteImageCommentLoader.Error), .failure(expectedError as RemoteImageCommentLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
}

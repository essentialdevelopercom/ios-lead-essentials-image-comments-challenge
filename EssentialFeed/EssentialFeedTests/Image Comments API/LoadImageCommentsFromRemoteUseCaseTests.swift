//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Bogdan Poplauschi on 27/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

final class RemoteCommentsLoader {
	
	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	typealias Result = Swift.Result<[ImageComment], Error>
	
	private let url: URL
	private let client: HTTPClient
	
	init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case .failure:
				completion(.failure(Error.connectivity))
				
			case let .success((data, response)):
				completion(RemoteCommentsLoader.map(data, from: response))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		guard response.statusCode == 200 else {
			return .failure(.invalidData)
		}
		
		do {
			let jsonDecoder = JSONDecoder()
			jsonDecoder.dateDecodingStrategy = .iso8601
			let root = try jsonDecoder.decode(Root.self, from: data)
			return .success(root.items.toModels())
		} catch {
			print(error)
			return .failure(.invalidData)
		}
	}
}

private extension Array where Element == RemoteImageComment {
	func toModels() -> [ImageComment] {
		return map {
			ImageComment(
				id: $0.id,
				message: $0.message,
				createdAt: $0.created_at,
				author: ImageCommentAuthor(username: $0.author.username))
		}
	}
}

private struct Root: Decodable {
	let items: [RemoteImageComment]
}

private struct RemoteImageComment: Decodable {
	let id: UUID
	let message: String
	let created_at: Date
	let author: RemoteImageCommentAuthor
}

private struct RemoteImageCommentAuthor: Decodable {
	let username: String
}

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load { _ in }
		sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(.connectivity), when: {
			client.complete(with: NSError(domain: "Test", code: 0))
		})
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		let samples = [199, 201, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(.invalidData), when: {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(.invalidData), when: {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}
	
	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .success([]), when: {
			let emptyListJSON = makeItemsJSON([])
			client.complete(withStatusCode: 200, data: emptyListJSON)
		})
	}
	
	func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		
		let item1 = makeItem(id: UUID(), message: "a message", authorName: "a username")
		
		let item2 = makeItem(id: UUID(), message: "another message", authorName: "another username")
		
		let items = [item1.model, item2.model]
		
		expect(sut, toCompleteWith: .success(items), when: {
			let json = makeItemsJSON([item1.json, item2.json])
			client.complete(withStatusCode: 200, data: json)
		})
	}
	
	// MARK: - Helpers
	
	private func expect(
		_ sut: RemoteCommentsLoader,
		toCompleteWith expectedResult: RemoteCommentsLoader.Result,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
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
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteCommentsLoader(url: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func makeItem(id: UUID, message: String, authorName: String) -> (model: ImageComment, json: [String: Any]) {
		let createdAt = Date(timeIntervalSinceReferenceDate: 638556190)
		let item = ImageComment(id: id, message: message, createdAt: createdAt, author: ImageCommentAuthor(username: authorName))
		
		let json = [
			"id": id.uuidString,
			"message": message,
			"created_at": ISO8601DateFormatter().string(from: createdAt),
			"author": [
				"username": authorName
			]
		].compactMapValues { $0 }
		
		return (item, json)
	}
	
	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
}

//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Lukas Bahrle Santana on 19/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed





struct RemoteImageComment: Decodable {
	let id: UUID
	let message: String
	let createdAt: Date
	let author: RemoteImageCommentAuthor
	
	enum CodingKeys: String, CodingKey{
		case id
		case message
		case createdAt = "created_at"
		case author
	}
}

struct RemoteImageCommentAuthor: Equatable, Decodable{
	let username:String
}

private struct Root: Decodable{
	let items: [RemoteImageComment]
}

class RemoteImageCommentsLoader{
	let client: HTTPClient
	let url: URL
	
	typealias Result = Swift.Result<[ImageComment], RemoteImageCommentsLoader.Error>
	
	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	init(client: HTTPClient, url: URL){
		self.client = client
		self.url = url
	}
	
	func load(completion: @escaping (Result) -> Void){
		client.get(from: url){ result in
			switch result{
			case .success((let data, let response)):
				if response.statusCode != 200 {
					completion(.failure(.invalidData))
				}
				else{
					let decoder = JSONDecoder()
					decoder.dateDecodingStrategy = .iso8601
					if let decodedRoot = try? decoder.decode(Root.self, from: data){
						completion(.success(decodedRoot.items.toModels()))
					}
					else{
						completion(.failure(.invalidData))
					}
				}
			case .failure(_):
				completion(.failure(.connectivity))
			}
		}
	}
}

private extension Array where Element == RemoteImageComment {
	func toModels() -> [ImageComment] {
		return map {ImageComment(id: $0.id, message: $0.message, createdAt: $0.createdAt, author: ImageCommentAuthor(username: $0.author.username))}
	}
}



class LoadImageCommentsFromRemoteUseCaseTests:XCTestCase{
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://comments-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load{ _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://comments-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load{ _ in }
		sut.load{ _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWith: .failure(.connectivity)) {
			client.complete(with: anyNSError())
		}
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199, 201, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: .failure(.invalidData)) {
				client.complete(withStatusCode: code, data: anyData(), at: index)
			}
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
		
		let item1 = makeItem(id: UUID(), message: "message-1", createdAt: "2020-05-20T11:24:59+0000", author: ImageCommentAuthor(username: "username-1"))
		
		let item2 = makeItem(id: UUID(), message: "message-2", createdAt: "2020-04-20T11:24:59+0000", author: ImageCommentAuthor(username: "username-2"))

		let items = [item1.model, item2.model]
		
		expect(sut, toCompleteWith: .success(items), when: {
			let json = makeItemsJSON([item1.json, item2.json])
			
			client.complete(withStatusCode: 200, data: json)
		})
	}
	
	
	// MARK: Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (RemoteImageCommentsLoader, HTTPClientSpy){
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client, url: url)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut)
		return (sut, client)
	}
	
	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func makeItem(id: UUID, message: String, createdAt: String, author: ImageCommentAuthor) -> (model: ImageComment, json: [String: Any]) {
		
		let dateCreatedAt = ISO8601DateFormatter().date(from: createdAt)!
		
		let item = ImageComment(id: id, message: message, createdAt: dateCreatedAt, author: author)
		
		let json:[String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt	,
			"author": [
				"username": author.username
			]
		]
		
		return (item, json)
	}
	
	private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load { receivedResult in
			
			switch (receivedResult, expectedResult){
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
			case let (.failure(receivedError), .failure(expectedError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
			default:
				XCTFail("Expected \(expectedResult) but got \(receivedResult)", file: file, line: line)
			}
			
			
			XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
}


//
//  LoadCommentFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Mayorga on 3/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import Foundation
import EssentialFeed

class RemoteCommentLoader {
	let url: URL
	let httpClient: HTTPClient
	
	typealias Result = Swift.Result<[Comment], Error>
	
	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	init(url: URL, client: HTTPClient) {
		self.url = url
		self.httpClient = client
	}
	
	func load(completion: @escaping (Result) -> Void) {
		httpClient.get(from: url) { [weak self] (result) in
			guard self != nil else { return }
			
			switch result {
			case .failure:
				completion(.failure(.connectivity))
				
			case let .success((data, response)):
				completion(RemoteCommentLoader.map(data, response: response))
			}
		}
	}
	
	static func map(_ data: Data, response: HTTPURLResponse) -> Result {
		do {
			let remoteComments = try CommentMapper.map(data, from: response)
			let comments = remoteComments.map { Comment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: CommentAuthor(username: $0.author.username))
			}
			
			return .success(comments)
		} catch {
			return .failure(RemoteCommentLoader.Error.invalidData)
		}
	}
}

struct RemoteComment: Decodable {
	let id: UUID
	let message: String
	let created_at: Date
	let author: CommentAuthor
}

class CommentMapper {
	private struct Root: Decodable {
		let items: [RemoteComment]
	}

	static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteComment] {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		guard response.statusCode == 200, let root = try? decoder.decode(Root.self, from: data) else {
			throw RemoteCommentLoader.Error.invalidData
		}
		
		return root.items
	}
}


class LoadCommentFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotRequestDataOnInit() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestDataFromURL() {
		let url = URL(string: "https://another-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load { (_) in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestDataFromURLTwice() {
		let url = URL(string: "https://another-url.com")!
		let (sut, client) = makeSUT(url: url)
		
		sut.load { (_) in }
		sut.load { (_) in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_requestDataFromRemoteDeliversClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut, client: client, expectedResult: .failure(.connectivity), action: {
			client.complete(with: RemoteCommentLoader.Error.connectivity)
		})
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		let statusCodes = [199, 201, 300, 400, 500]
		
		statusCodes.enumerated().forEach { index, code in
			expect(sut, client: client, expectedResult: .failure(.invalidData)) {
				client.complete(withStatusCode: code, data: Data.init(), at: index)
			}
		}
	}
	
	func test_load_deliversEmptyDataOn200HTTPResponseWithEmptyDataResponse() {
		let (sut, client) = makeSUT()
		
		expect(sut, client: client, expectedResult: .success([])) {
			client.complete(withStatusCode: 200, data: Data("{\"items\": []}".utf8))
		}
	}
	
	func test_load_deliversReceivedNonEmptyDataOn200HTTTPResponse() {
		let (sut, client) = makeSUT()
		let (model, json) = makeCommentData()

		expect(sut, client: client, expectedResult: .success(model)) {
			client.complete(withStatusCode: 200, data: json)
		}
	}
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let url = URL(string: "https://a-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteCommentLoader? = RemoteCommentLoader(url: url, client: client)
		
		var capturedResults = [RemoteCommentLoader.Result]()
		sut?.load(completion: { (result) in
			capturedResults.append(result)
		})
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeCommentData().1)
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	// MARK: - Helpers
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteCommentLoader, spy: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteCommentLoader(url: url, client: client)
		
		return (sut, client)
	}

	private func expect(_ sut: RemoteCommentLoader, client: HTTPClientSpy, expectedResult: RemoteCommentLoader.Result, action: () -> Void) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load { (receivedResult) in
			XCTAssertEqual(receivedResult, expectedResult)
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func makeCommentData() -> ([Comment], Data) {
		let date1 = ISO8601DateFormatter().date(from: "2020-05-20T11:24:59+0000")!
		let commentAuthor1 = CommentAuthor(username: "a username")
		let comment1 = Comment(
			id: UUID(),
			message: "a comment message",
			createdAt: date1,
			author: commentAuthor1
		)
		
		let comment1JSON: [String: Any] = [
			"id": comment1.id.uuidString,
			"message": comment1.message,
			"created_at": "2020-05-20T11:24:59+0000",
			"author": [
				"username": comment1.author.username
			]
		]

		let date2 = ISO8601DateFormatter().date(from: "2020-05-19T14:23:53+0000")!
		let commentAuthor2 = CommentAuthor(username: "another username")
		let comment2 = Comment(
			id: UUID(),
			message: "another comment message",
			createdAt: date2,
			author: commentAuthor2
		)

		let comment2JSON: [String: Any] = [
			"id": comment2.id.uuidString,
			"message": comment2.message,
			"created_at": "2020-05-19T14:23:53+0000",
			"author": [
				"username": comment2.author.username
			]
		]

		let commentsArray = [comment1, comment2]
		let commentsJSON = ["items" : [comment1JSON, comment2JSON]]
		let commentsData = try! JSONSerialization.data(withJSONObject: commentsJSON)

		return (commentsArray, commentsData)
	}
}

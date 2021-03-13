//
//  Created by Azamat Valitov on 13.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedCommentsLoader {
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	private let client: HTTPClient
	init(client: HTTPClient) {
		self.client = client
	}
	
	func load(url: URL, completion: @escaping (Result<[FeedComment], Error>)->()) {
		client.get(from: url, completion: { result in
			switch result {
			case .success(let (data, response)):
				let decoder = JSONDecoder()
				decoder.dateDecodingStrategy = .iso8601
				if response.statusCode == 200, let root = try? decoder.decode(Root.self, from: data) {
					completion(.success(root.items.map({FeedComment(id: $0.id, message: $0.message, date: $0.created_at, authorName: $0.author.username)})))
				}else{
					completion(.failure(.invalidData))
				}
			case .failure:
				completion(.failure(.connectivity))
			}
		})
	}
}

private struct Root: Decodable {
	let items: [RemoteFeedComment]
}

private struct RemoteFeedComment: Decodable {
	let id: UUID
	let message: String
	let created_at: Date
	let author: RemoteAuthor
}

private struct RemoteAuthor: Decodable {
	let username: String
}

class LoadFeedCommentsFromRemoteUseCaseTests: XCTestCase {
	
	func test_init_doesNotRequestData() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT()
		
		sut.load(url: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT()
		
		sut.load(url: url) { _ in }
		sut.load(url: url) { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut: sut, toCompleteWith: .failure(RemoteFeedCommentsLoader.Error.connectivity)) {
			client.complete(with: anyNSError())
		}
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199, 201, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut: sut, toCompleteWith: .failure(RemoteFeedCommentsLoader.Error.invalidData)) {
				client.complete(withStatusCode: code, data: self.emptyItemsData(), at: index)
			}
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut: sut, toCompleteWith: .failure(RemoteFeedCommentsLoader.Error.invalidData)) {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		}
	}
	
	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		expect(sut: sut, toCompleteWith: .success([])) {
			client.complete(withStatusCode: 200, data: self.emptyItemsData())
		}
	}
	
	func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		
		let item1 = makeFeedCommentWithJSON(id: UUID(),
											message: "a message",
											date: "2020-05-20T11:24:59+0000",
											authorName: "an author name")
		let item2 = makeFeedCommentWithJSON(id: UUID(),
											message: "another message",
											date: "2020-05-19T14:23:53+0000",
											authorName: "another name")
		
		expect(sut: sut, toCompleteWith: .success([item1.comment, item2.comment])) {
			let json = ["items": [
				item1.json,
				item2.json
			]]
			let data = try! JSONSerialization.data(withJSONObject: json)
			client.complete(withStatusCode: 200, data: data)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedCommentsLoader(client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func expect(sut: RemoteFeedCommentsLoader, toCompleteWith expectedResult: Result<[FeedComment], Error>, on actions: @escaping ()->(), file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		sut.load(url: anyURL()) { receivedResult in
			switch (receivedResult, expectedResult) {
			case (.success(let receivedComments), .success(let expectedComments)):
				XCTAssertEqual(receivedComments, expectedComments, file: file, line: line)
			case (.failure(let receivedError), .failure(let expectedError)):
				XCTAssertEqual(receivedError, expectedError as? RemoteFeedCommentsLoader.Error, file: file, line: line)
			default:
				XCTFail("Expected: \(expectedResult), but received: \(receivedResult)", file: file, line: line)
			}
			exp.fulfill()
		}
		
		actions()
		
		let result = XCTWaiter.wait(for: [exp], timeout: 1.0)
		switch result {
		case .timedOut:
			XCTFail("Timed out waiting for load completion", file: file, line: line)
		default:
			break
		}
	}
	
	private func emptyItemsData() -> Data {
		let json = ["items": []]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func makeFeedCommentWithJSON(id: UUID, message: String, date: String, authorName: String) -> (comment: FeedComment, json: [String: Any]) {
		let dateFormatter = ISO8601DateFormatter()
		let json: [String: Any] = ["id": id.uuidString,
								   "message": message,
								   "created_at": date,
								   "author": [
									   "username": authorName
								   ]]
		let comment = FeedComment(id: id, message: message, date: dateFormatter.date(from: date)!, authorName: authorName)
		return (comment, json)
	}
}

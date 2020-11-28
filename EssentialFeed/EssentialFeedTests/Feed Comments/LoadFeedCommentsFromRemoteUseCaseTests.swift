//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import XCTest
import EssentialFeed

struct Root: Decodable {
	let items: [FeedImageComment]
}

struct FeedImageComment: Decodable, Equatable {
	
	struct Author: Decodable {
		let username: String
	}
	
	let id: UUID
	let message: String
	let createdAt: Date
	let author: Author
	
	static func == (lhs: FeedImageComment, rhs: FeedImageComment) -> Bool {
		return lhs.id == rhs.id
			&& lhs.message == rhs.message
			&& lhs.createdAt == rhs.createdAt
			&& lhs.author.username == rhs.author.username
	}
}

final class RemoteFeedCommentsLoader {
	
	typealias Result = Swift.Result<[FeedImageComment], Error>
	
	private let url: URL
	private let client: HTTPClient
	
	enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				
				if !response.isOK {
					completion(.failure(.invalidData))
				} else {
					guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
						return completion(.failure(.invalidData))
					}
					completion(.success(root.items))
				}
				
			case .failure(_):
				completion(.failure(.connectivity))
			}
		}
	}
}

class LoadFeedCommentsFromRemoteUseCaseTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURLTwice() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load() { _ in }
		sut.load() { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWithResult: .failure(.connectivity)) {
			let expectedError = RemoteFeedCommentsLoader.Error.connectivity
			client.complete(with: expectedError)
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWithResult: .failure(.invalidData)) {
			let invalidJson = Data("Invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJson)
		}
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		[199, 401, 300, 400, 500].enumerated().forEach { index, errorCode in
			
			expect(sut, toCompleteWithResult: .failure(.invalidData)) {
				client.complete(withStatusCode: errorCode, data: anyData(), at: index)
			}
		}
	}
	
	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWithResult: .success([])) {
			let emptyListJSON = makeItemJSON([])
			client.complete(withStatusCode: 200, data: emptyListJSON)
		}
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(),file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedCommentsLoader(url: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
	private func expect(_ sut: RemoteFeedCommentsLoader, toCompleteWithResult expectedResult: RemoteFeedCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		
		let exp = expectation(description: "Waiting for load completion")
		
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedResult), .success(expectedResult)):
				XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
			case let (.failure(receivedError), .failure(expectedError)):
				XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
			default:
				XCTFail("Expected result \(expectedResult) got \(receivedResult) instead.", file: file, line: line)
			}
			exp.fulfill()
		}
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func makeItemJSON(_ items: [[String: Any]]) -> Data {
		let json = [ "items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
}

extension HTTPURLResponse {
	var isOK: Bool {
		return (200...299).contains(statusCode)
	}
}


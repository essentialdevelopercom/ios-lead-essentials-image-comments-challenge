//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import XCTest
import EssentialFeed

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
	
	func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()
		let date = Date()
		let item1 = makeItem(id: UUID(), message: "First message", createdAt: date, author: "First author")
		let item2 = makeItem(id: UUID(), message: "Second message", createdAt: date, author: "Second author")
		
		expect(sut, toCompleteWithResult: .success([item1, item2].toModels())) {
			let json = makeItemJSON([item1, item2])
			client.complete(withStatusCode: 200, data: json)
		}
	}
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let url = URL(string: "https://a-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteFeedCommentsLoader? = RemoteFeedCommentsLoader(url: url, client: client)
		
		var capturedResult = [RemoteFeedCommentsLoader.Result]()
		sut?.load { capturedResult.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeItemJSON([]))
		
		XCTAssertTrue(capturedResult.isEmpty)
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
	
	private func makeItemJSON(_ items: [CodableFeedImageComment]) -> Data {
		let encoder = JSONEncoder()
		let root = FeedImageCommentsMapper.Root(items: items)
		return try! encoder.encode(root)
	}
	
	private func makeItem(id: UUID = UUID(), message: String = "Any message", createdAt: Date = Date(), author name: String = "Author Name") -> CodableFeedImageComment {
		let author = CodableFeedImageComment.Author(username: name)
		let item = CodableFeedImageComment(id: id, message: message, created_at: createdAt, author: author)
		return item
	}
	
}

extension HTTPURLResponse {
	var isOK: Bool {
		return (200...299).contains(statusCode)
	}
}


private extension Array where Element == CodableFeedImageComment {
	 func toModels() -> [ImageComment] {
		 map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: $0.author.username) }
	 }
 }

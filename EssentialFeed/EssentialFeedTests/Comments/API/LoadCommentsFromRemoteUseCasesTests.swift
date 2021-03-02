//
//  LoadCommentsFromRemoteUseCasesTests.swift
//  EssentialFeediOSTests
//
//  Created by Robert Dates on 1/19/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadCommentsFromRemoteUseCasesTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestDataFromURL() {
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	func test_loadTwice_requestsDataFromURL() {
		
		let url = anyURL()
		let (sut, client) = makeSUT(url: url)
		
		sut.load { _ in }
		sut.load { _ in }
		
		XCTAssertEqual(client.requestedURLs, [url, url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		expect(sut, toCompleteWith: failure(RemoteCommentLoader.Error.connectivity)) {
			let clientError = anyNSError()
			client.complete(with: clientError)
		}
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) =  makeSUT()
		
		let samples = [199, 201, 300, 400, 500]
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				client.complete(withStatusCode: code, data: Data(), at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponeWithInvalidJSON() {
		let (sut, client) = makeSUT()
		
		let acceptedStatusCodes = [200, 201, 245, 298, 299]

		acceptedStatusCodes.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData), when: {
				let invalidJsonData = Data("invalid data".utf8)
				client.complete(withStatusCode: code, data: invalidJsonData, at: index)
			})
		}
	}
	
	func test_load_deliversNoItemsOn200HTTPReponseWithEmptyJSONList() {
		let acceptedStatusCodes = [200, 201, 245, 298, 299]

		acceptedStatusCodes.enumerated().forEach { index, code in
			let (sut, client) = makeSUT()
			expect(sut, toCompleteWith: success([]), when: {
				let emptyListJSON = makeItemsJSON([])
				client.complete(withStatusCode: code, data: emptyListJSON)
			})
		}
	}
	
	func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
		let author = Author(username: "a username")
		let item1 = makeItem(id: UUID(), author: author)
		
		let item2 = makeItem(id: UUID(), author: author)
		
		let items = [item1.model, item2.model]
		
		let acceptedStatusCodes = [200, 201, 245, 298, 299]

		acceptedStatusCodes.enumerated().forEach { index, code in
			let (sut, client) = makeSUT()
			expect(sut, toCompleteWith: .success(items), when: {
				let json = makeItemsJSON([item1.json, item2.json])
				client.complete(withStatusCode: code, data: json)
			})
		}
			
	}
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let client = HTTPClientSpy()
		let url = URL(string: "http://any-url.com")!
		var sut: RemoteCommentLoader? = RemoteCommentLoader(client: client, url: url)
		
		var capturedResults = [CommentLoader.Result]()
		sut?.load { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCommentLoader, client: HTTPClientSpy) {
		let client =  HTTPClientSpy()
		let sut = RemoteCommentLoader(client: client, url: url)
		trackForMemoryLeaks(client)
		trackForMemoryLeaks(sut)
		
		return (sut, client)
	}
	
	private func failure(_ error: RemoteCommentLoader.Error) -> CommentLoader.Result {
		return .failure(error)
	}
	
	private func success(_ comments: [Comment]) -> CommentLoader.Result {
		return .success(comments)
	}

	private func expect(_ sut: RemoteCommentLoader, toCompleteWith expectedResult: Result<[Comment], Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")

		sut.load { receivedResult in
			switch (expectedResult, receivedResult) {
			case let (.success(expectedComments),
					  .success(receivedComments)):
				XCTAssertEqual(expectedComments, receivedComments, file: file, line: line)

			case let (.failure(expectedError as RemoteCommentLoader.Error),
					  .failure(receivedError as RemoteCommentLoader.Error)):
				XCTAssertEqual(expectedError, receivedError, file: file, line: line)

			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}

			exp.fulfill()
		}

		action()

		wait(for: [exp], timeout: 2.0)
	}
	
	private func makeItem(id: UUID, message: String = "", createdAt: Date = Date(), author: Author) -> (model: Comment, json: [String: Any]) {

		let date = (actual: Date(timeIntervalSince1970: 1598627222), string: "2020-08-28T15:07:02+00:00")
		let item = Comment(id: id, message: message, createdAt: date.actual, author: author)
		let json = [
			"id": id.uuidString,
			"message": message,
			"created_at": date.string,
			"author": ["username": author.username]
		].compactMapValues { $0 }
		return (item, json)
	}
}

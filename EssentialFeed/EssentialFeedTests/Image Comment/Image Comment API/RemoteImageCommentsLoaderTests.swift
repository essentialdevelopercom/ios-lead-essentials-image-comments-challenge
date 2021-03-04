//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 01/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteImageCommentsLoaderTests: XCTestCase {
	func test_init_doesNotRequestDataFromUrl() {
		let (_, client) = makeSUT()
		
		XCTAssertEqual(client.requestedURLs, [])
	}
	
	func test_everyTimeloadIsCalled_requestsDataFromUrl() {
		let (sut, client) = makeSUT()
		let url = URL(string: "https://a-url.com")!
		
		_ = sut.load { _ in }
		XCTAssertEqual(client.requestedURLs, [url])
		
		_ = sut.load { _ in }
		_ = sut.load { _ in }
		XCTAssertEqual(client.requestedURLs, [url,url,url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		expect(sut: sut, toCompleteWith: failure(.connectivity), when: {
			client.complete(with: NSError())
		})
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		let statusCodes = [111,222,300,400,500]
		
		statusCodes.enumerated().forEach { index, code in
			expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
				let json = makeItemsJSON([])
				client.complete(withStatusCode: code, data: json, at: index)
			})
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()
		let invalidJSON = Data("invalid json".utf8)
		
		expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
			client.complete(withStatusCode: 200, data: invalidJSON)
		})
	}
	
	func test_load_deliversEmptyCommentsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		let emptyJSON = Data("{\"items\":[]}".utf8)
		
		expect(sut: sut, toCompleteWith: .success([]), when: {
			client.complete(withStatusCode: 200, data: emptyJSON)
		})
	}
	
	func test_load_deliversCommentsOn200ResponseWithValidJSONList() {
		let (sut, client) = makeSUT()
		
		let (comment1, commentJSON1) = makeImageItem(id: UUID(),
												   message: "a message",
												   created_at: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
												   username: "user")
		let (comment2, commentJSON2) = makeImageItem(id: UUID(),
												   message: "another message",
												   created_at: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
												   username: "another user")
		
		let validJSON = makeItemsJSON([commentJSON1, commentJSON2])
		
		expect(sut: sut, toCompleteWith: .success([comment1,comment2]), when: {
				client.complete(withStatusCode: 200, data: validJSON)
		})
	}
	
	func test_load_doesNotDeliverResultAfterCancellingTask() {
		let (sut, client) = makeSUT()
		let nonEmptyData = Data("non-empty data".utf8)
		
		var received = [ImageCommentsLoader.Result]()
		let task = sut.load { received.append($0) }
		task.cancel()
		
		client.complete(withStatusCode: 404, data: anyData())
		client.complete(withStatusCode: 200, data: nonEmptyData)
		client.complete(with: anyNSError())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
	}
	
	func test_load_shouldNotDeliverResultOnDeallocation() {
		let url = URL(string: "https://a-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(client: client, url: url)
		
		var capturedResults = [RemoteImageCommentsLoader.Result]()
		_ = sut?.load { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	//MARK: Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy){
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client, url: url)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut,client)
	}
	
	private func expect(sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		_ = sut.load() { recievedResult in
			switch (recievedResult, expectedResult) {
			case let (.failure(recievedError as RemoteImageCommentsLoader.Error),
					  .failure(expectedError as RemoteImageCommentsLoader.Error)):
				XCTAssertEqual(recievedError, expectedError, file: file, line: line)
			case let (.success(recievedComments),
					  .success(expectedComments)):
				XCTAssertEqual(recievedComments, expectedComments, file: file, line: line)
			default:
				XCTFail("Expected result: \(expectedResult), got: \(recievedResult) instead", file: file, line: line)
			}
		}
		
		action()
	}
	
	private func makeImageItem(id: UUID, message: String, created_at: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
		let author = CommentAuthor(username: username)
		let comment = ImageComment(id: id, message: message, createdDate: created_at.date, author: author)
		
		let authorJSON = [
			"username": author.username
		]
		let commentJSON = [
			"id": comment.id.uuidString,
			"message": comment.message,
			"created_at": created_at.iso8601String,
			"author": authorJSON
		] as [String: Any]
		
		return (comment, commentJSON)
	}
	
	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let json = ["items": items]
		return try! JSONSerialization.data(withJSONObject: json)
	}
	
	private func failure(_ error: RemoteImageCommentsLoader.Error) -> ImageCommentsLoader.Result {
		return .failure(error)
	}
}

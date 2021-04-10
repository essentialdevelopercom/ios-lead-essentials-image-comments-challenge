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

class LoadImageCommentFromRemoteUseCaseTests: XCTestCase {
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
		
		expect(sut, client: client, expectedResult: .failure(RemoteImageCommentLoader.Error.connectivity), action: {
			client.complete(with: RemoteImageCommentLoader.Error.connectivity)
		})
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		let statusCodes = [199, 201, 300, 400, 500]
		
		statusCodes.enumerated().forEach { index, code in
			expect(sut, client: client, expectedResult: .failure(RemoteImageCommentLoader.Error.invalidData)) {
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
		let (model, json) = makeImageCommentData()

		expect(sut, client: client, expectedResult: .success(model)) {
			client.complete(withStatusCode: 200, data: json)
		}
	}
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let url = URL(string: "https://a-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteImageCommentLoader? = RemoteImageCommentLoader(url: url, client: client)
		
		var capturedResults = [ImageCommentLoader.LoadImageCommentResult]()
		_ = sut?.load(completion: { (result) in
			capturedResults.append(result)
		})
		
		sut = nil
		client.complete(withStatusCode: 200, data: makeImageCommentData().1)
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	// MARK: - Helpers
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentLoader, spy: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentLoader(url: url, client: client)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, client)
	}

	private func expect(_ sut: RemoteImageCommentLoader, client: HTTPClientSpy, expectedResult: ImageCommentLoader.LoadImageCommentResult, action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for load completion")
		
		_ = sut.load { (receivedResult) in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
				
			case let (.failure(receivedError as RemoteImageCommentLoader.Error), .failure(expectedError as RemoteImageCommentLoader.Error)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)
				
			default:
				XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
			}
			
			exp.fulfill()
		}
		
		action()
		
		wait(for: [exp], timeout: 1.0)
	}
	
	private func makeImageCommentData() -> ([ImageComment], Data) {
		let imageComment1 = makeImageComment("a comment message", createdAt: "2020-05-20T11:24:59+0000", authorUsername: "a username")
		let imageComment1JSON = makeImageCommentJSON(from: imageComment1)

		let imageComment2 = makeImageComment("another comment message", createdAt: "2020-05-19T14:23:53+0000", authorUsername: "another username")
		let imageComment2JSON = makeImageCommentJSON(from: imageComment2)

		let commentsArray = [imageComment1, imageComment2]
		let commentsJSON = ["items" : [imageComment1JSON, imageComment2JSON]]
		let commentsData = try! JSONSerialization.data(withJSONObject: commentsJSON)

		return (commentsArray, commentsData)
	}
	
	private func makeImageComment(_ message: String, createdAt: String, authorUsername: String) -> ImageComment {
		let date = ISO8601DateFormatter().date(from: createdAt)!
		let commentAuthor = ImageCommentAuthor(username: authorUsername)
		let imageComment = ImageComment(
			id: UUID(),
			message: message,
			createdAt: date,
			author: commentAuthor
		)
		
		return imageComment
	}
	
	private func makeImageCommentJSON(from imageComment: ImageComment) -> [String: Any] {
		let imageCommentJSON: [String: Any] = [
			"id": imageComment.id.uuidString,
			"message": imageComment.message,
			"created_at": ISO8601DateFormatter().string(from: imageComment.createdAt),
			"author": [
				"username": imageComment.author.username
			]
		]
		
		return imageCommentJSON
	}
}

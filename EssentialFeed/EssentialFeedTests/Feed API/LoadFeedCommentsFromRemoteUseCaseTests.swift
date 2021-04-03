//
//  Created by Azamat Valitov on 13.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

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
	
	func test_load_deliversErrorOnNon2xxHTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199, 300, 400, 500]
		
		samples.enumerated().forEach { index, code in
			expect(sut: sut, toCompleteWith: .failure(RemoteFeedCommentsLoader.Error.invalidData)) {
				client.complete(withStatusCode: code, data: self.emptyItemsData(), at: index)
			}
		}
	}
	
	func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
		let invalidJSON = Data("invalid json".utf8)
		expectLoad(toCompleteWith: .failure(RemoteFeedCommentsLoader.Error.invalidData), data: invalidJSON, forEveryStatusCodesIn: [200, 201, 250, 299])
	}
	
	func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
		expectLoad(toCompleteWith: .success([]), data: emptyItemsData(), forEveryStatusCodesIn: [200, 201, 250, 299])
	}
	
	func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() {
		let item1 = makeFeedCommentWithJSON(id: UUID(),
											message: "a message",
											createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
											authorName: "an author name")
		let item2 = makeFeedCommentWithJSON(id: UUID(),
											message: "another message",
											createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
											authorName: "another name")
		let json = ["items": [
			item1.json,
			item2.json
		]]
		let data = try! JSONSerialization.data(withJSONObject: json)
		
		expectLoad(toCompleteWith: .success([item1.comment, item2.comment]), data: data, forEveryStatusCodesIn: [200, 201, 250, 299])
	}
	
	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let url = anyURL()
		let client = HTTPClientSpy()
		var sut: RemoteFeedCommentsLoader? = RemoteFeedCommentsLoader(client: client)
		
		var capturedResults = [Result<[FeedComment], Error>]()
		sut?.load(url: url) { capturedResults.append($0) }
		
		sut = nil
		client.complete(withStatusCode: 200, data: emptyItemsData())
		
		XCTAssertTrue(capturedResults.isEmpty)
	}
	
	func test_cancelFeedCommentsLoaderTask_cancelsClientURLRequest() {
		let (sut, client) = makeSUT()
		let url = anyURL()
		
		let task = sut.load(url: url, completion: {_ in })
		XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
		
		task.cancel()
		XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
	}
	
	func test_load_doesNotDeliverResultAfterCancellingTask() {
		let (sut, client) = makeSUT()
		let nonEmptyData = Data("non-empty data".utf8)
		
		var received = [FeedCommentsLoader.Result]()
		let task = sut.load(url: anyURL()) { received.append($0) }
		task.cancel()
		
		client.complete(withStatusCode: 404, data: anyData())
		client.complete(withStatusCode: 200, data: nonEmptyData)
		client.complete(with: anyNSError())
		
		XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
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
				XCTAssertEqual(receivedError as? RemoteFeedCommentsLoader.Error, expectedError as? RemoteFeedCommentsLoader.Error, file: file, line: line)
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
	
	private func makeFeedCommentWithJSON(id: UUID, message: String, createdAt: (date: Date, stringRepresentation: String), authorName: String) -> (comment: FeedComment, json: [String: Any]) {
		let json: [String: Any] = ["id": id.uuidString,
								   "message": message,
								   "created_at": createdAt.stringRepresentation,
								   "author": [
									   "username": authorName
								   ]]
		let comment = FeedComment(id: id, message: message, date: createdAt.date, authorName: authorName)
		return (comment, json)
	}
	
	private func expectLoad(toCompleteWith expectedResult: Result<[FeedComment], Error>, data: Data, forEveryStatusCodesIn statusCodes: [Int], file: StaticString = #filePath, line: UInt = #line) {
		let (sut, client) = makeSUT()
		statusCodes.enumerated().forEach { index, code in
			expect(sut: sut, toCompleteWith: expectedResult, on: {
				client.complete(withStatusCode: code, data: data, at: index)
			}, file: file, line: line)
		}
	}
	
}

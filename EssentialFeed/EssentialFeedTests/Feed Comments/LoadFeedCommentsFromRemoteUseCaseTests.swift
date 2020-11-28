//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import XCTest
import EssentialFeed

final class RemoteFeedCommentsLoader {
	
	typealias Result = Swift.Result<Data, Error>
	
	private let url: URL
	private let client: HTTPClient
	
	init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	
	func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .failure(error):
				completion(.failure(error))
			default:
				break
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
		let expectedError = anyNSError()
		let (sut, client) = makeSUT()
		
		let exp = expectation(description: "Waiting for request completion")
		sut.load { result in
			switch result {
			case let .failure(receivedError):
				XCTAssertEqual(expectedError, receivedError as NSError?)
			default:
				XCTFail("Expecting to receive an error, got the \(result) instead.")
			}
			exp.fulfill()
		}
		
		client.complete(with: expectedError)
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(),file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedCommentsLoader(url: url, client: client)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
	
}

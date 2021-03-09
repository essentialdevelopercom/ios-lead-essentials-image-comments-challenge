//
//  LoadFeedImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ivan Ornes on 9/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

public protocol FeedImageCommentsLoaderTask {
	func cancel()
}

public protocol FeedImageCommentsLoader {
	typealias Result = Swift.Result<Data, Error>
	
	func loadImageComments(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageCommentsLoaderTask
}

public final class RemoteFeedImageCommentsLoader: FeedImageCommentsLoader {
	
	private final class HTTPClientTaskWrapper: FeedImageCommentsLoaderTask {
		func cancel() {
		}
	}
	
	public func loadImageComments(from url: URL, completion: @escaping (FeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
		completion(.success("".data(using: .utf8)!))
		return HTTPClientTaskWrapper()
	}
}

class LoadFeedImageCommentsFromRemoteUseCaseTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageCommentsLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedImageCommentsLoader()
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(client, file: file, line: line)
		return (sut, client)
	}
}

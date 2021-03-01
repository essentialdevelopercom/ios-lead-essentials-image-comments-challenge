//
//  FeedImageCommentsTests.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct FeedComment {
	let id: UUID
	let message: String
	let createdAt: String
	let author: FeedCommentAuthor
}

struct FeedCommentAuthor {
	let username: String
}

class RemoteImageFeedCommentLoader {
	
	private let baseUrl: URL
	private let client: HTTPClient
	
	init(baseUrl: URL, client: HTTPClient) {
		self.baseUrl = baseUrl
		self.client = client
	}
	
	func load(imageId: String, completion: @escaping (Result<[FeedComment], Error>) -> Void) {
		client.get(from: baseUrl, completion: { _ in })
	}
	
}

final class FeedImageCommentsTests: XCTestCase {

	func test_init_doesNotRequestDataFromUrl() {
		let (_, client) = makeSUT()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
		let (loader, client) = makeSUT(url: url)

		loader.load(imageId: "any", completion: { _ in })

		XCTAssertEqual(client.requestedURLs, [url])
	}
	
	private func makeSUT(url: URL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!) -> (RemoteImageFeedCommentLoader, HTTPClientSpy) {
		let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
		let client = HTTPClientSpy()
		let loader = RemoteImageFeedCommentLoader(baseUrl: url, client: client)

		return (loader, client)
	}
	
}

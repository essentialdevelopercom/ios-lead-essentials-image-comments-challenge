//
//  RemoteImageCommentsLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Cronay on 13.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteImageCommentsLoader {
	private let client: HTTPClient
	private let url: URL

	init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}

	func load() {
		client.get(from: url) { _ in }
	}
}

class RemoteImageCommentsLoaderTests: XCTestCase {

	func test_init_doesNotRequestFromURL() {
		let client = HTTPClientSpy()
		_ = RemoteImageCommentsLoader(client: client, url: anyURL())

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsFromURL() {
		let commentsURL = URL(string: "http://comments-url.com")!
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client, url: commentsURL)

		sut.load()

		XCTAssertEqual(client.requestedURLs, [commentsURL])
	}
}

//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 08/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

public final class RemoteImageCommentsLoader {
	private let client: HTTPClient

	public init(client: HTTPClient) {
		self.client = client
	}

	public func load(from url: URL) {
		client.get(from: url) { _ in }
	}
}

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

	func test_init_doesNotPerformURLRequest() {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client)

		trackForMemoryLeaks(sut)

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsDataFromURL() {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client)

		let url = URL(string: "https://a-given-url.com")!
		sut.load(from: url)

		XCTAssertEqual(client.requestedURLs, [url])
	}
}

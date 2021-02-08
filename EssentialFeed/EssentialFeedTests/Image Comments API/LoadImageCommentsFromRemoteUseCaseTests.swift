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

	public init(client: HTTPClient) {}
}

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

	func test_init_doesNotPerformURLRequest() {
		let client = HTTPClientSpy()
		let sut = RemoteImageCommentsLoader(client: client)

		trackForMemoryLeaks(sut)

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
}

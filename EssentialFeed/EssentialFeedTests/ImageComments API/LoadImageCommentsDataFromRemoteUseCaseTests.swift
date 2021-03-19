//
//  LoadImageCommentsDataFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sebastian Vidrea on 19.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

class RemoteImageCommentsLoader {

}

class LoadImageCommentsDataFromRemoteUseCaseTests: XCTestCase {

	func test_init_doesNotRequestDataFromURL() {
		let client = HTTPClientSpy()
		let _ = RemoteImageCommentsLoader()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

}

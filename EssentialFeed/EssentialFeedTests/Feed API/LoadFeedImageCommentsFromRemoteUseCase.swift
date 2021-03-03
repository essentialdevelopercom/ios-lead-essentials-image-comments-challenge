//
//  LoadFeedImageCommentsFromRemoteUseCase.swift
//  EssentialFeedTests
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedImageCommentsLoader {
	let client: HTTPClient
	
	init(client: HTTPClient) {
		self.client = client
	}
}

class LoadFeedImageCommentsFromRemoteUseCase: XCTestCase {
	
	func test_init_doesNotRequestsDataFromURL() {
		let client = HTTPClientSpy()
		let _ = RemoteFeedImageCommentsLoader(client: client)
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
}

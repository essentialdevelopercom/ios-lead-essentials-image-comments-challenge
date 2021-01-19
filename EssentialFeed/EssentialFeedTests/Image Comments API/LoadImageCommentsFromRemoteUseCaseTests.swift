//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Lukas Bahrle Santana on 19/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteImageCommentsLoader{
	let client: HTTPClient
	
	init(client: HTTPClient){
		self.client = client
	}
}

class LoadImageCommentsFromRemoteUseCaseTests:XCTestCase{
	func test_init_doesNotRequestDataFromURL() {
		let client = HTTPClientSpy()
		_ = RemoteImageCommentsLoader(client: client)
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
}


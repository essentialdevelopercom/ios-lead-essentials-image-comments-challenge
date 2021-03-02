//
//  LoadImageCommentsFromRemoteUseCase.swift
//  EssentialFeedTests
//
//  Created by Adrian Szymanowski on 02/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsRemoteLoader {
	init(client: HTTPClient) {
		
	}
}

class LoadImageCommentsFromRemoteUseCase: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let client = HTTPClientSpy()
		let _ = ImageCommentsRemoteLoader(client: client)
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
	
}

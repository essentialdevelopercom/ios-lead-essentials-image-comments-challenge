//
//  CommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Khoi Nguyen on 24/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest

class CommentLoader {
	init(client: Any) {
		
	}
}

class CommentLoaderTests: XCTestCase {
	func test_init_doesNotRequestComment() {
		let client = ClientSpy()
		_ = CommentLoader(client: client)
		
		XCTAssertTrue(client.requestedURLs.isEmpty, "Expected no requested url upon creation")
	}
	
	// MARK: - Helpers
	class ClientSpy {
		var requestedURLs: [URL] = []
	}
}

//
//  LoadCommentFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Mayorga on 3/4/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import Foundation

class RemoteCommentLoader {}

class LoadCommentFromRemoteUseCaseTests: XCTestCase {
	func test_init_doesNotRequestDataOnInit() {
		let client = HTTPClientSpy()
		_ = RemoteCommentLoader()
		
		XCTAssertTrue(client.requestedURLs.isEmpty)
	}
}

// MARK: - Helpers


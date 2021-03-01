//
//  RemoteCommentLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Eric Garlock on 2/28/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

private class RemoteCommentLoader {
	
	var requestURLCount: Int = 0
	
	
}

class RemoteCommentLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let loader = RemoteCommentLoader()
		
		XCTAssertEqual(loader.requestURLCount, 0)
	}
	
}

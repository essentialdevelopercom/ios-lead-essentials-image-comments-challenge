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
	
	public func load() {
		requestURLCount += 1
	}
	
}

class RemoteCommentLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		let sut = makeSUT()
		
		XCTAssertEqual(sut.requestURLCount, 0)
	}
	
	func test_load_requestsDataFromURL() {
		let sut = makeSUT()
		
		sut.load()
		
		XCTAssertEqual(sut.requestURLCount, 1)
	}
	
	func test_load_requestsDataFromURLTwice() {
		let sut = makeSUT()
		
		sut.load()
		sut.load()
		
		XCTAssertEqual(sut.requestURLCount, 2)
	}
	
	// MARK: - Helpers
	private func makeSUT() -> RemoteCommentLoader {
		let sut = RemoteCommentLoader()
		trackForMemoryLeaks(sut)
		return sut
	}
	
	
}

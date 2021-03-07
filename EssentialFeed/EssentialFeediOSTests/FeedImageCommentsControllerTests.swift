//
//  FeedImageCommentsControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Anton Ilinykh on 07.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

final class FeedImageCommentsController {
	init(loader: FeedImageCommentsControllerTests.LoaderSpy) {
		
	}
}

final class FeedImageCommentsControllerTests: XCTestCase {
	
	func test_load_doesNotLoadCommetns() {
		let loader = LoaderSpy()
		let _ = FeedImageCommentsController(loader: loader)
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	// MARK: - Helpers
	
	class LoaderSpy {
		private(set) var loadCallCount = 0
		
		func load() {
			loadCallCount += 1
		}
	}
}

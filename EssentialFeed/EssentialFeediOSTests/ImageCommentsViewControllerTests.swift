//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ángel Vázquez on 20/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class ImageCommentsViewController {
	init(loader: ImageCommentsViewControllerTests.LoaderSpy) {
		
	}
}

class ImageCommentsViewControllerTests: XCTestCase {
	func test_init_doesNotLoadComments() {
		let loader = LoaderSpy()
		_ = ImageCommentsViewController(loader: loader)
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	// MARK: - Helpers
	
	class LoaderSpy {
		private(set) var loadCallCount = 0
	}
}

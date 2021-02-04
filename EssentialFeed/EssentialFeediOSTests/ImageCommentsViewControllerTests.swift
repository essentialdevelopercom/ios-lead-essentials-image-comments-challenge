//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Alok Subedi on 04/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsViewController {
	init(loader: ImageCommentsViewControllerTests.LoaderSpy) {
		
	}
}

class ImageCommentsViewControllerTests: XCTestCase {

	func test_init_doesNotLoadImageComments() {
		let loader = LoaderSpy()
		_ = ImageCommentsViewController(loader: loader)
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	//MARK: Helpers
	
	class LoaderSpy {
		var loadCallCount = 0
	}
}

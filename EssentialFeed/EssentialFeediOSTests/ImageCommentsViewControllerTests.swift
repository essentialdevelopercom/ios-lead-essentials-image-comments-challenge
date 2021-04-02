//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

final class ImageCommentsViewController {
	init(loader: ImageCommentsViewControllerTests.LoaderSpy) {

	}
}

final class ImageCommentsViewControllerTests: XCTestCase {

	func test_init_doesNotLoadImageComments() {
		let loader = LoaderSpy()
		_ = ImageCommentsViewController(loader: loader)

		XCTAssertEqual(loader.loadCallCount, 0)
	}

	// MARK: - Helpers

	class LoaderSpy {
		private(set) var loadCallCount: Int = 0
	}

}

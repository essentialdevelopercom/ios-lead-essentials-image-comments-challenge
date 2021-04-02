//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit

final class ImageCommentsViewController: UIViewController {
	private var loader: ImageCommentsViewControllerTests.LoaderSpy?

	convenience init(loader: ImageCommentsViewControllerTests.LoaderSpy) {
		self.init()
		self.loader = loader
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		loader?.load()
	}
}

final class ImageCommentsViewControllerTests: XCTestCase {

	func test_init_doesNotLoadImageComments() {
		let loader = LoaderSpy()
		_ = ImageCommentsViewController(loader: loader)

		XCTAssertEqual(loader.loadCallCount, 0)
	}

	func test_viewDidLoad_loadsImageComments() {
		let loader = LoaderSpy()
		let sut = ImageCommentsViewController(loader: loader)

		sut.loadViewIfNeeded()

		XCTAssertEqual(loader.loadCallCount, 1)
	}

	// MARK: - Helpers

	class LoaderSpy {
		private(set) var loadCallCount: Int = 0

		func load() {
			loadCallCount += 1
		}
	}

}

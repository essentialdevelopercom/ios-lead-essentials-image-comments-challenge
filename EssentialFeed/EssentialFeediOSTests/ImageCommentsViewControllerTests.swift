//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed

final class ImageCommentsViewController: UIViewController {
	private var loader: ImageCommentsLoader?

	convenience init(loader: ImageCommentsLoader) {
		self.init()
		self.loader = loader
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		loader?.load { _ in }
	}
}

final class ImageCommentsViewControllerTests: XCTestCase {

	func test_init_doesNotLoadImageComments() {
		let (_, loader) = makeSUT()

		XCTAssertEqual(loader.loadCallCount, 0)
	}

	func test_viewDidLoad_loadsImageComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(loader.loadCallCount, 1)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsViewController(loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	class LoaderSpy: ImageCommentsLoader {
		private(set) var loadCallCount: Int = 0

		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) {
			loadCallCount += 1
		}
	}

}

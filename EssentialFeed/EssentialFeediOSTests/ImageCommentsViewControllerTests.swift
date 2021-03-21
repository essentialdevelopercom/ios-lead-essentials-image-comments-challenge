//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ángel Vázquez on 20/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest
import UIKit

class ImageCommentsViewController: UIViewController {
	
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

class ImageCommentsViewControllerTests: XCTestCase {
	func test_init_doesNotLoadComments() {
		let loader = LoaderSpy()
		_ = ImageCommentsViewController(loader: loader)
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	func test_viewDidLoad_loadsComments() {
		let loader = LoaderSpy()
		let sut = ImageCommentsViewController(loader: loader)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadCallCount, 1)
	}
	
	// MARK: - Helpers
	
	class LoaderSpy {
		private(set) var loadCallCount = 0
		
		func load() {
			loadCallCount += 1
		}
	}
}

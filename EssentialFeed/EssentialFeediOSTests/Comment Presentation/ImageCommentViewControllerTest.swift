//
//  ImageCommentViewControllerTest.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Mayorga on 3/17/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed

final class ImageCommentViewController: UIViewController {
	private var loader: ImageCommentLoader?
	
	convenience init(loader: ImageCommentLoader) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loader?.load { _ in }
	}
}

class ImageCommentViewControllerTest: XCTestCase {
	func test_init_doesNotLoadFeed() {
		let loader = LoaderSpy()
		_ = ImageCommentViewController(loader: loader)
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	// Load feed when presented
	func test_viewDidLoad_loadsFeed() {
		let loader = LoaderSpy()
		let sut = ImageCommentViewController(loader: loader)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadCallCount, 1)
	}
	
	// MARK: - Helpers
	
	class LoaderSpy: ImageCommentLoader {
		private(set) var loadCallCount: Int = 0
		
		func load(completion: @escaping (LoadImageCommentResult) -> Void) {
			loadCallCount += 1
		}
	}
}


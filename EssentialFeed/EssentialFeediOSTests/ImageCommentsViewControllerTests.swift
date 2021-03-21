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
	
	private var url: URL!
	private var loader: ImageCommentLoader?
	
	convenience init(url: URL, loader: ImageCommentLoader) {
		self.init()
		self.url = url
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_ = loader?.load(from: url) { _ in }
	}
}

class ImageCommentsViewControllerTests: XCTestCase {
	func test_init_doesNotLoadComments() {
		let loader = LoaderSpy()
		let url = URL(string: "https://any-url.com")!
		_ = ImageCommentsViewController(url: url, loader: loader)
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	func test_viewDidLoad_loadsComments() {
		let loader = LoaderSpy()
		let url = URL(string: "https://any-url.com")!
		let sut = ImageCommentsViewController(url: url, loader: loader)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadCallCount, 1)
	}
	
	// MARK: - Helpers
	
	class LoaderSpy: ImageCommentLoader {
		private(set) var loadCallCount = 0
		
		struct Task: ImageCommentLoaderTask {
			func cancel() { }
		}
		
		func load(from url: URL, completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderTask {
			loadCallCount += 1
			return Task()
		}
	}
}

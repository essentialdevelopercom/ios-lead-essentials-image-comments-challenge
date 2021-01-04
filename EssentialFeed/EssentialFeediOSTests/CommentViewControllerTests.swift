//
//  CommentViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Khoi Nguyen on 30/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
import EssentialFeed
import UIKit


public class CommentViewController: UITableViewController {
	private var loader: CommentLoader?
	
	convenience init(loader: CommentLoader) {
		self.init()
		self.loader = loader
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		loader?.load { _ in }
	}
}

class CommentViewControllerTests: XCTestCase {
	
	func test_init_doesNotLoadComment() {
		let loader = LoaderSpy()
		_ = CommentViewController(loader: loader)
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	func test_viewDidLoad_loadsComment() {
		let loader = LoaderSpy()
		let sut = CommentViewController(loader: loader)
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadCallCount, 1)
	}
	
	// MARK: - Helpers
	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}
	
	class LoaderSpy: CommentLoader {
		var loadCallCount = 0
		
		func load(completion: @escaping (CommentLoader.Result) -> Void) {
			loadCallCount += 1
		}
	}
}


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

final class ImageCommentViewController: UITableViewController {
	private var loader: ImageCommentLoader?
	
	convenience init(loader: ImageCommentLoader) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.beginRefreshing()
		
		loader?.load { _ in }
	}
}

class ImageCommentViewControllerTest: XCTestCase {
	func test_init_doesNotLoadFeed() {
		let (_, loader) = makeSUT()
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	func test_viewDidLoad_loadsFeed() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadCallCount, 1)
	}
	
	func test_viewDidLoad_displaysLoadingIndicator() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.isShowingLoadingIndicator, true)
	}
	
//	func test_viewDidLoad_failToLoadFeed() {
//		let (sut, _) = makeSUT()
//		
//		sut.loadViewIfNeeded()
//		
//		XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
//	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentViewController(loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	class LoaderSpy: ImageCommentLoader {
		private var completions = [(LoadImageCommentResult) -> Void]()
		var loadCallCount: Int { return completions.count }
		
		func load(completion: @escaping (LoadImageCommentResult) -> Void) {
			completions.append(completion)
		}
	}
}

private extension ImageCommentViewController {
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
}

//
//  FeedImageCommentsControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Anton Ilinykh on 07.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedImageCommentsController: UITableViewController {
	
	private var loader: FeedImageCommentsLoader!
	
	convenience init(loader: FeedImageCommentsLoader) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		refreshControl?.beginRefreshing()
		load()
	}
	
	@objc private func load() {
		loader.load { _ in }
	}
}

final class FeedImageCommentsControllerTests: XCTestCase {
	
	func test_load_doesNotLoadCommetns() {
		let (_, loader) = makeSUT()
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	func test_viewDidLoad_loadsFeed() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadCallCount, 1)
	}
	
	func test_pullToRefresh_loadsFeed() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		sut.refreshControl?.simulatePullToRefresh()
		XCTAssertEqual(loader.loadCallCount, 2)
		
		sut.refreshControl?.simulatePullToRefresh()
		XCTAssertEqual(loader.loadCallCount, 3)
	}
	
	func test_viewDidLoad_showsLoadingIndicator() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
	}
	
	func test_pullToRefresh_showsLoadingIndicator() {
		let (sut, _) = makeSUT()
		
		sut.refreshControl?.simulatePullToRefresh()
		
		XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageCommentsController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedImageCommentsController(loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	class LoaderSpy: FeedImageCommentsLoader {
		private(set) var loadCallCount = 0
		
		func load(completion: @escaping (FeedImageCommentsLoader.Result) -> Void) {
			loadCallCount += 1
		}
	}
}

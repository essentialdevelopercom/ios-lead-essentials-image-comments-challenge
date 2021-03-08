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
		loader.load { [weak self] _ in
			self?.refreshControl?.endRefreshing()
		}
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
	
	func test_viewDidLoad_hidesLoadingIndicatorOnLoadingCompletion() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading()
		
		XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
	}
	
	func test_pullToRefresh_showsLoadingIndicator() {
		let (sut, _) = makeSUT()
		
		sut.refreshControl?.simulatePullToRefresh()
		
		XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
	}
	
	func test_pullToRefresh_hidesLoadingIndicatorOnLoadingCompletion() {
		let (sut, loader) = makeSUT()
		
		sut.refreshControl?.simulatePullToRefresh()
		loader.completeCommentsLoading()
		
		XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
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
		private var completions = [(FeedImageCommentsLoader.Result) -> Void]()
		var loadCallCount: Int {
			return completions.count
		}
		
		func load(completion: @escaping (FeedImageCommentsLoader.Result) -> Void) {
			completions.append(completion)
		}
		
		func completeCommentsLoading() {
			completions[0](.success([]))
		}
	}
}

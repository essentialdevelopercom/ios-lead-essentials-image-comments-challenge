//
//  FeedImageCommentsControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Anton Ilinykh on 07.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedImageCommentsControllerTests: XCTestCase {
	
	func test_loadCommentsAction_requestsCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCallCount, 0, "Expecting no loading requests before loadView is called")
	
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1, "Expecting a loading request once a view is loaded")
		
		sut.simulateUserInitiatedCommentsReload()
		XCTAssertEqual(loader.loadCallCount, 2, "Expecting another loading request once user initiates a load")
		
		sut.simulateUserInitiatedCommentsReload()
		XCTAssertEqual(loader.loadCallCount, 3, "Expecting a third loading request once user initiates another load")
	}
	
	func test_loadingIndicator_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expecting a loading indicator once a view is loaded")
		
		loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expecting no loading indicator once loading is completed")
	
		sut.simulateUserInitiatedCommentsReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expecting a loading indicator once user initiated a reload")
	
		loader.completeCommentsLoading(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expecting no loading indicator once user initiated loading is completed")
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
		
		func completeCommentsLoading(at: Int) {
			completions[at](.success([]))
		}
	}
}

private extension FeedImageCommentsController {
	func simulateUserInitiatedCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
}

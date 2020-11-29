
//  Created by Maxim Soldatov on 11/29/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class FeedImageCommentsUIIntegrationTests: XCTestCase {
	
	func test_loadCommentsAction_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedCommentsReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedCommentsReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}
	
	func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
		 let (sut, loader) = makeSUT()

		 sut.loadViewIfNeeded()
		 XCTAssertEqual(sut.isShowingLoadingIndicator, true)

		 loader.completeCommentsLoading()
		 XCTAssertEqual(sut.isShowingLoadingIndicator, false)
	 }
	
	//MARK: -Helpers
	
	private func makeSUT(url: URL = anyURL(),file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedImageCommentsUIComposer.imageCommentsComposeWith(commentsLoader: loader, url: url)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private class LoaderSpy: FeedImageCommentsLoader {
		var loadCommentsCallCount: Int {
			return completions.count
		}
		var completions = [(FeedImageCommentsLoader.Result) -> Void]()
		
		private struct Task: FeedImageCommentsLoaderTask {
			func cancel() {}
		}
		
		func load(from _: URL, completion: @escaping (FeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
			completions.append(completion)
			return Task()
		}
		
		func completeCommentsLoading(at index: Int = 0) {
			completions[index](.success([]))
		}
	}
	
}

private extension FeedImageCommentsViewController {
	func simulateUserInitiatedCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
}


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
		
		sut.simulateUserInitiatedCommentsReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeCommentsLoading(with: anyNSError())
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	 }
	
	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let currentDate = Date()
		
		
		let comment1 = ImageComment(id: UUID(), message: "First message", createdAt: currentDate.adding(days: -2), author: "First Author")
		let comment2 = ImageComment(id: UUID(), message: "Second message", createdAt: currentDate.adding(seconds: -305), author: "Second Author")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment1, comment2])
		
		let cell1 = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FeedImageCommentCell
		
		XCTAssertEqual(cell1?.usernameLabel?.text, "First Author")
		XCTAssertEqual(cell1?.creationTimeLabel?.text, "2 days ago")
		XCTAssertEqual(cell1?.commentLabel?.text, "First message")
		
		let cell2 = sut.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? FeedImageCommentCell
		XCTAssertEqual(cell2?.usernameLabel?.text, "Second Author")
		XCTAssertEqual(cell2?.creationTimeLabel?.text, "5 minutes ago")
		XCTAssertEqual(cell2?.commentLabel?.text, "Second message")
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
		
		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			completions[index](.success(comments))
		}
		
		func completeCommentsLoading(with error: Error, at index: Int = 0) {
			completions[index](.failure(error))
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


extension Date {
	
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
	
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}

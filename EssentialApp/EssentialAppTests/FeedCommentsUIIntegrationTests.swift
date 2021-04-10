//
//  Created by Azamat Valitov on 14.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialApp
import EssentialFeed
import EssentialFeediOS

class FeedCommentsUIIntegrationTests: XCTestCase {
	
	func test_feedCommentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("FEED_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadFeedCommentsActions_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedFeedCommentsReload()
		XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
		
		sut.simulateUserInitiatedFeedCommentsReload()
		XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}
	
	func test_loadingFeedCommentsIndicator_isVisibleWhileLoadingFeedComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
		
		sut.simulateUserInitiatedFeedCommentsReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	}
	
	func test_loadFeedCommentsCompletion_rendersSuccessfullyLoadedFeedComments() {
		let calendar = Calendar(identifier: .gregorian)
		let comment0 = makeComment(
			message: "any message",
			date: Date().adding(days: -1, calendar: calendar),
			authorName: "any name"
		)
		let comment1 = makeComment(
			message: "another message",
			date: Date().adding(hours: -1, calendar: calendar),
			authorName: "another name"
		)
		let comment2 = makeComment(
			message: "different message",
			date: Date().adding(mins: -3, calendar: calendar),
			authorName: "different name"
		)
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])
		
		sut.simulateUserInitiatedFeedCommentsReload()
		loader.completeCommentsLoading(with: [comment0, comment1, comment2], at: 1)
		assertThat(sut, isRendering: [comment0, comment1, comment2])
	}
	
	func test_loadFeedCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
		let comment0 = makeComment()
		let comment1 = makeComment()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment0, comment1], at: 0)
		assertThat(sut, isRendering: [comment0, comment1])
		
		sut.simulateUserInitiatedFeedCommentsReload()
		loader.completeCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	func test_loadFeedCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment = makeComment()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment], at: 0)
		assertThat(sut, isRendering: [comment])
		
		sut.simulateUserInitiatedFeedCommentsReload()
		loader.completeCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment])
	}
	
	func test_loadFeedCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("FEED_COMMENTS_VIEW_CONNECTION_ERROR"))
		
		sut.simulateUserInitiatedFeedCommentsReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_errorViewIsHidden_whenUserTapsOnIt() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		loader.completeCommentsLoadingWithError(at: 0)
		
		XCTAssertEqual(sut.errorMessage, localized("FEED_COMMENTS_VIEW_CONNECTION_ERROR"))
		
		sut.errorView.simulateTap()
		
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_deinit_cancelsRunningRequest() {
		let taskSpy = TaskSpy()
		let loader = LoaderSpy(taskSpy: taskSpy)
		
		var sut: FeedCommentsViewController?
		
		autoreleasepool {
			sut = FeedCommentsUIComposer.commentsComposedWith(feedCommentsLoader: loader)
			sut?.loadViewIfNeeded()
		}
		
		XCTAssertEqual(taskSpy.cancelCount, 0)
		
		sut = nil
		
		XCTAssertEqual(taskSpy.cancelCount, 1)
	}
	
	func test_loadFeedCommentsCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeCommentsLoading(with: [], at: 0)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedCommentsUIComposer.commentsComposedWith(feedCommentsLoader: loader, locale: locale)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private var locale: Locale {
		Locale(identifier: "en_US_POSIX")
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "FeedComments"
		let bundle = Bundle(for: FeedCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class TaskSpy: FeedCommentsLoaderTask {
		var cancelCount = 0
		
		func cancel() {
			cancelCount += 1
		}
	}
	
	private class LoaderSpy: FeedCommentsLoader {
		
		private var commentsRequests: [(FeedCommentsLoader.Result) -> Void] = []
		private let taskSpy: TaskSpy
		
		init(taskSpy: TaskSpy = TaskSpy()) {
			self.taskSpy = taskSpy
		}
		
		func load(completion: @escaping (FeedCommentsLoader.Result) -> Void) -> FeedCommentsLoaderTask {
			commentsRequests.append(completion)
			return taskSpy
		}
		
		func completeCommentsLoading(with comments: [FeedComment] = [], at index: Int = 0) {
			commentsRequests[index](.success(comments))
		}
		
		func completeCommentsLoadingWithError(at index: Int = 0) {
			commentsRequests[index](.failure(anyNSError()))
		}
		
		var loadCallCount: Int {
			commentsRequests.count
		}
	}
	
	private func assertThat(_ sut: FeedCommentsViewController, isRendering comments: [FeedComment], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		guard sut.numberOfRenderedFeedCommentViews() == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedFeedCommentViews()) instead.", file: file, line: line)
		}
		
		let viewModels = FeedCommentsPresenter.convertToViewModels(comments: comments, locale: locale)
		viewModels.enumerated().forEach { index, comment in
			assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
		}
		
		executeRunLoopToCleanUpReferences()
	}
	
	private func assertThat(_ sut: FeedCommentsViewController, hasViewConfiguredFor comment: FeedCommentViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		XCTAssertEqual(sut.commentUsername(at: index), comment.name, "author name at index (\(index))", file: file, line: line)
		
		XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at index (\(index)", file: file, line: line)
		
		XCTAssertEqual(sut.commentDate(at: index), comment.formattedDate, "date at index (\(index)", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
	
	private func makeComment(message: String = "any message", date: Date = Date(), authorName: String = "any name") -> FeedComment {
		return FeedComment(id: UUID(), message: message, date: date, authorName: authorName)
	}
}

private extension ErrorView {
	func simulateTap() {
		subviews.compactMap({$0 as? UIButton}).first?.simulateTap()
	}
}

private extension Date {
	func adding(days: Int, calendar: Calendar) -> Date {
		return calendar.date(byAdding: .day, value: days, to: self)!
	}
	
	func adding(hours: Int, calendar: Calendar) -> Date {
		return calendar.date(byAdding: .hour, value: hours, to: self)!
	}
	
	func adding(mins: Int, calendar: Calendar) -> Date {
		return calendar.date(byAdding: .minute, value: mins, to: self)!
	}
}

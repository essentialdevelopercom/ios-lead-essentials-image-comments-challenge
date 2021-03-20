//
//  Created by Azamat Valitov on 14.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedCommentsUIIntegrationTests: XCTestCase {
	
	func test_feedCommentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("FEED_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadFeedCommentsActions_requestCommentsFromLoader() {
		let url = URL(string: "https://comments-url.com")!
		let (sut, loader) = makeSUT(url: url)
		XCTAssertEqual(loader.loadedUrls, [], "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadedUrls, [url], "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedFeedCommentsReload()
		XCTAssertEqual(loader.loadedUrls, [url, url], "Expected another loading request once user initiates a reload")
		
		sut.simulateUserInitiatedFeedCommentsReload()
		XCTAssertEqual(loader.loadedUrls, [url, url, url], "Expected yet another loading request once user initiates another reload")
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
		let comment0 = FeedComment(id: UUID(), message: "a message", date: Date(), authorName: "an author name")
		let comment1 = FeedComment(id: UUID(), message: "another message", date: Date(), authorName: "another author name")
		let comment2 = FeedComment(id: UUID(), message: "some message", date: Date(), authorName: "some author name")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])
		
		sut.simulateUserInitiatedFeedCommentsReload()
		loader.completeCommentsLoading(with: [comment0, comment1, comment2], at: 1)
		assertThat(sut, isRendering: [comment0, comment1, comment2])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedCommentsViewController(url: url, loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "FeedComments"
		let bundle = Bundle(for: FeedCommentsViewController.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	class LoaderSpy: FeedCommentsLoader {
		
		private(set) var loadedUrls: [URL] = []
		private var commentsRequests: [(FeedCommentsLoader.Result) -> Void] = []
		
		func load(url: URL, completion: @escaping (FeedCommentsLoader.Result) -> Void) {
			loadedUrls.append(url)
			commentsRequests.append(completion)
		}
		
		func completeCommentsLoading(with comments: [FeedComment] = [], at index: Int = 0) {
			commentsRequests[index](.success(comments))
		}
		
		func completeCommentsLoadingWithError(at index: Int = 0) {
			commentsRequests[index](.failure(anyNSError()))
		}
	}
	
	func assertThat(_ sut: FeedCommentsViewController, isRendering comments: [FeedComment], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		guard sut.numberOfRenderedFeedCommentViews() == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedFeedCommentViews()) instead.", file: file, line: line)
		}
		
		comments.enumerated().forEach { index, comment in
			assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
		}
		
		executeRunLoopToCleanUpReferences()
	}
	
	func assertThat(_ sut: FeedCommentsViewController, hasViewConfiguredFor comment: FeedComment, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.feedCommentView(at: index)
		
		guard let cell = view as? FeedCommentCell else {
			return XCTFail("Expected \(FeedCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.authorName, comment.authorName, "Expected author name to be \(String(describing: comment.authorName)) for comment view at index (\(index))", file: file, line: line)
		
		XCTAssertEqual(cell.message, comment.message, "Expected message to be \(String(describing: comment.message)) for comment view at index (\(index)", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
}

extension FeedCommentsViewController {
	func simulateUserInitiatedFeedCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	func numberOfRenderedFeedCommentViews() -> Int {
		return tableView.numberOfRows(inSection: feedCommentsSection)
	}
	
	private var feedCommentsSection: Int {
		return 0
	}
	
	func feedCommentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedFeedCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
}

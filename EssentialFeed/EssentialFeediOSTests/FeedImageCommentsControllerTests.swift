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
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let comment0 = makeComment(message: "Comment 0", author: "Author 0")
		let comment1 = makeComment(message: "Comment 1", author: "Author 1")
		let comment2 = makeComment(message: "Comment 2", author: "Author 2")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		assert(sut, isRendering: [])
		
		loader.completeCommentsLoading(with: [comment0], at: 0)
		assert(sut, isRendering: [comment0])
		
		sut.simulateUserInitiatedCommentsReload()
		loader.completeCommentsLoading(with: [comment0, comment1, comment2], at: 1)
		assert(sut, isRendering: [comment0, comment1, comment2])
	}
	
	func test_loadImageCommentsCompletion_doesNotAlteringCurrentRenderingStateOnError() {
		let comment0 = makeComment()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment0], at: 0)
		assert(sut, isRendering: [comment0])
		
		sut.simulateUserInitiatedCommentsReload()
		loader.completeCommentsLoadingWithError(at: 1)
		assert(sut, isRendering: [comment0])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageCommentsController, loader: LoaderSpy) {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let loader = LoaderSpy()
//		let sut = FeedImageCommentsController(loader: loader)
		let sut = storyboard.instantiateViewController(identifier: "FeedImageCommentsController") as! FeedImageCommentsController
		sut.loader = loader
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func assert(_ sut: FeedImageCommentsController, isRendering comments: [FeedImageComment], file: StaticString = #file, line: UInt = #line) {
		guard sut.numberOfRenderedFeedImageCommentViews == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedFeedImageCommentViews) instead", file: file, line: line)
		}
		comments.enumerated().forEach { index, comment in
			assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
		}
	}
	
	private func assertThat(_ sut: FeedImageCommentsController, hasViewConfiguredFor comment: FeedImageComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
		let view = sut.feedImageCommentView(at: index)
		
		guard let cell = view as? FeedImageCommentCell else {
			return XCTFail("Expected \(FeedImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.author, comment.author.username, "Expected author to be \(comment.author.username) for comment at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.date, comment.createdAt, "Expected date to be \(comment.createdAt) for comment at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.comment, comment.message, "Expected message to be \(comment.message) for comment at index \(index)", file: file, line: line)
	}
	
	private func makeComment(id: UUID = UUID(), message: String = "message", createdAt: String = "now", author: String = "author") -> FeedImageComment {
		return FeedImageComment(id: id, message: message, createdAt: createdAt, author: FeedImageComment.Author(username: author))
	}
	
	class LoaderSpy: FeedImageCommentsLoader {
		private var completions = [(FeedImageCommentsLoader.Result) -> Void]()
		var loadCallCount: Int {
			return completions.count
		}
		
		func load(completion: @escaping (FeedImageCommentsLoader.Result) -> Void) {
			completions.append(completion)
		}
		
		func completeCommentsLoading(with comments: [FeedImageComment] = [], at: Int) {
			completions[at](.success(comments))
		}
		
		func completeCommentsLoadingWithError(at: Int) {
			let error = NSError(domain: "an error", code: 0)
			completions[at](.failure(error))
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
	
	var numberOfRenderedFeedImageCommentViews: Int {
		return tableView.numberOfRows(inSection: 0)
	}
	
	func feedImageCommentView(at index: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let indexPath = IndexPath(row: index, section: 0)
		return ds?.tableView(tableView, cellForRowAt: indexPath)
	}
}

private extension FeedImageCommentCell {
	var author: String? {
		return authorLabel.text
	}
	
	var date: String? {
		return dateLabel.text
	}
	
	var comment: String? {
		return commentLabel.text
	}
}

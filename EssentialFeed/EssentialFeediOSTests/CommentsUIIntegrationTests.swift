//
//  CommentsControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Anton Ilinykh on 07.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class CommentsUIIntegrationTests: XCTestCase {
	
	func test_commentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("COMMENTS_VIEW_TITLE"))
	}
	
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
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expecting no loading indicator once loading is completed successfully")
	
		sut.simulateUserInitiatedCommentsReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expecting a loading indicator once user initiated a reload")
	
		loader.completeCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expecting no loading indicator once user initiated loading is failed with error")
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
	
	func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		let exp = expectation(description: "Wait for loading completes")
		DispatchQueue.global().async {
			loader.completeCommentsLoading(with: [], at: 0)
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: CommentsController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
		let table = "Feed"
		let bundle = Bundle(for: CommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private func assert(_ sut: CommentsController, isRendering comments: [Comment], file: StaticString = #file, line: UInt = #line) {
		guard sut.numberOfRenderedCommentViews == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedCommentViews) instead", file: file, line: line)
		}
		comments.enumerated().forEach { index, comment in
			assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
		}
	}
	
	private func assertThat(_ sut: CommentsController, hasViewConfiguredFor comment: Comment, at index: Int, file: StaticString = #file, line: UInt = #line) {
		let view = sut.CommentView(at: index)
		
		guard let cell = view as? CommentCell else {
			return XCTFail("Expected \(CommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.author, comment.author.username, "Expected author to be \(comment.author.username) for comment at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.date, comment.createdAt, "Expected date to be \(comment.createdAt) for comment at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.comment, comment.message, "Expected message to be \(comment.message) for comment at index \(index)", file: file, line: line)
	}
	
	private func makeComment(id: UUID = UUID(), message: String = "message", createdAt: String = "now", author: String = "author") -> Comment {
		return Comment(id: id, message: message, createdAt: createdAt, author: Comment.Author(username: author))
	}
	
	class LoaderSpy: CommentsLoader {
		private var completions = [(CommentsLoader.Result) -> Void]()
		var loadCallCount: Int {
			return completions.count
		}
		
		func load(completion: @escaping (CommentsLoader.Result) -> Void) {
			completions.append(completion)
		}
		
		func completeCommentsLoading(with comments: [Comment] = [], at: Int) {
			completions[at](.success(comments))
		}
		
		func completeCommentsLoadingWithError(at: Int) {
			let error = NSError(domain: "an error", code: 0)
			completions[at](.failure(error))
		}
	}
}

private extension CommentsController {
	func simulateUserInitiatedCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	var numberOfRenderedCommentViews: Int {
		return tableView.numberOfRows(inSection: 0)
	}
	
	func CommentView(at index: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let indexPath = IndexPath(row: index, section: 0)
		return ds?.tableView(tableView, cellForRowAt: indexPath)
	}
}

private extension CommentCell {
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

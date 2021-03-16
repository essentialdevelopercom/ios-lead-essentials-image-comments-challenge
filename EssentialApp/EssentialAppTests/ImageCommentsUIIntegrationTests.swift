//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 09/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
@testable import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsUIIntegrationTests: XCTestCase {
	
	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadImageCommentsAction_requestImageCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 1, "Expected a loading request once view is loaded")
	}
	
	func test_loadingImageCommentsIndicator_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeImageCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to disable loading indicator while loading completes with success")
		
		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeImageCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to disable loading indicator while loading completes with an error")
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let comment1 = makeImageComment()
		let comment2 = makeImageComment()
		let comment3 = makeImageComment()
		let comment4 = makeImageComment()
		let comment5 = makeImageComment()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
				
		loader.completeImageCommentsLoading(with: [comment1], at: 0)
		assertThat(sut, isRendering: [comment1])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoading(with: [comment1, comment2, comment3, comment4, comment5], at: 1)
		assertThat(sut, isRendering: [comment1, comment2, comment3, comment4, comment5])
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsListAfterNonEmptyResponse() {
		let comment1 = makeImageComment()
		let comment2 = makeImageComment()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment1, comment2], at: 0)
		assertThat(sut, isRendering: [comment1, comment2])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	func test_loadImageCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment1 = makeImageComment()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment1], at: 0)
		assertThat(sut, isRendering: [comment1])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment1])
	}
	
	func test_loadImageCommentsCompletion_redersErrorMessageConErrorUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeImageCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR"))
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_imageCommentsView_cancelsCommentsLoadingWhenViewIsNotVisibleAnymore() {
		let url = URL(string: "http://some-stub-url.com")!
		let (sut, loader) = makeSUT(stubURL: url)

		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator to show up")
		XCTAssertEqual(loader.cancelledURL, [], "Expected no cancelled URL during normal lodaing state")
		
		sut.cancelImageLoadingTask()
		XCTAssertEqual(loader.cancelledURL, [url], "Expected to cancel URL when sut is deinitialized")
	}
	
	func test_loadImageCommentsCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeImageCommentsLoading(at: 0)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helper
	
	private func makeSUT(stubURL: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy(url: stubURL)
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(imageCommentsLoader: loader)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		return (sut, loader)
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, isRendering comments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		let numberOfRenderedComments = sut.numberOfRenderedImageCommentsViews()
		guard numberOfRenderedComments == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(numberOfRenderedComments) instead", file: file, line: line)
		}
		
		comments
			.enumerated()
			.forEach { index, comment in
				assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
			}
		
		executeRunLoopToCleanUpReferences()
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor comment: ImageComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.authorUsername, comment.author.username, "Expected author username to be \(String(describing: comment.author.username)) for comment view at index (\(index))", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
	
	private func makeImageComment() -> ImageComment {
		ImageComment(id: UUID(), message: "a message", createdAt: Date(), author: ImageComment.Author(username: "an username"))
	}
	
	private class LoaderSpy: ImageCommentsLoader, ImageCommentsViewControllerDelegate {
		private struct TaskSpy: ImageCommmentsLoaderTask {
			let cancelCallback: () -> Void
			func cancel() { cancelCallback() }
		}
		
		private(set) var commentsRequestHandlers = [(ImageCommentsLoader.Result) -> Void]()
		var loadImageCommentsCallCount: Int { commentsRequestHandlers.count }
		
		private(set) var cancelledURL = [URL]()
		
		private let url: URL
		
		init(url: URL) {
			self.url = url
		}
		
		func didRequestImageCommentsRefresh() {
			_ = loadImageComments { _ in }
		}
		
		func didCancelImageCommentsLoading() {}
		
		func loadImageComments(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommmentsLoaderTask {
			commentsRequestHandlers.append(completion)
			return TaskSpy { [weak self] in
				guard let self = self else { return }
				self.cancelledURL.append(self.url)
			}
		}
		
		func completeImageCommentsLoading(at index: Int) {
			commentsRequestHandlers[index](.success([]))
		}
		
		func completeImageCommentsLoadingWithError(at index: Int) {
			commentsRequestHandlers[index](.failure(anyNSError()))
		}
		
		func completeImageCommentsLoading(with comments: [ImageComment], at index: Int) {
			commentsRequestHandlers[index](.success(comments))
		}
	}
	
}

private extension ImageCommentsUIIntegrationTests {
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}

private extension ImageCommentsViewController {
	var isShowingLoadingIndicator: Bool {
		refreshControl?.isRefreshing ?? false
	}
	
	var errorMessage: String? {
		errorView?.message
	}
	
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	func numberOfRenderedImageCommentsViews() -> Int {
		tableView.numberOfRows(inSection: commentsSectionIndex)
	}
	
	private var commentsSectionIndex: Int { 0 }
	
	func imageCommentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedImageCommentsViews() > row else {
			return nil
		}
		
		let dataSource = tableView.dataSource
		let index = IndexPath(row: row, section: commentsSectionIndex)
		return dataSource?.tableView(tableView, cellForRowAt: index)
	}
}


//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class CommentsUIIntegrationTests: XCTestCase {
	
	func test_commentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadCommentActions_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		
		XCTAssertEqual(loader.loadCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(loader.loadCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 2, "Expected another loading request once user initiates a load")
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 3, "Expected a third loading request once user initiates another load")
	}
	
	func test_loadingCommentsIndicator_whileLoadingComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show the loading indicator when view did load and loader hasn't complete loading yet")

		loader.completeLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected not to show the loading indicator after the loader did finish loading")

		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected to show the loading indicator when the user initiates a reload")

		loader.completeLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected not to show the loading indicator after loading completed with an error")
	}
	
	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let date = Date()
		let comment0 = makeComment(id: UUID(), message: "message0", date: (date: date.adding(days: -1), string: "1 day ago"), author: "author0")
		let comment1 = makeComment(id: UUID(), message: "message1", date: (date: date.adding(days: -3), string: "3 days ago"), author: "author1")
		let comment2 =  makeComment(id: UUID(), message: "message2", date: (date: date.adding(days: -31), string: "1 month ago"), author: "author2")
		let comment3 = makeComment(id: UUID(), message: "message3", date: (date: date.adding(days: -366), string: "1 year ago"), author: "author3")
		let comment4 = makeComment(id: UUID(), message: "message4", date: (date: date.adding(days: -1), string: "1 day ago"), author: "author4")
		let (sut, loader) = makeSUT(currentDate: { date }, locale: .init(identifier: "en_US_POSIX"))

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])

		loader.completeLoading(with: [comment0.model], at: 0)
		assertThat(sut, isRendering: [comment0.expected])

		sut.simulateUserInitiatedReload()
		loader.completeLoading(with: [comment0.model, comment1.model, comment2.model, comment3.model, comment4.model], at: 1)
		assertThat(sut, isRendering: [comment0.expected, comment1.expected, comment2.expected, comment3.expected, comment4.expected])
	}
	
	func test_loadCommentsCompletion_rendersErrorMessageOnLoaderFailureUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("COMMENTS_VIEW_CONNECTION_ERROR"))

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_cancelCommentsLoading_whenViewIsDismissed() {
		let loader = LoaderSpy()
		var sut: CommentsViewController?

		autoreleasepool {
			sut = CommentUIComposer.commentsComposedWith(loader: loader.loadPublisher)
			sut?.loadViewIfNeeded()
		}

		XCTAssertEqual(loader.cancelCount, 0, "Loading should not be cancelled when view just did load")

		sut = nil
		XCTAssertEqual(loader.cancelCount, 1, "Loading should be cancelled when view is about to disappear")
	}
	
	func test_loadCommentCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let date = Date()
		let comment0 = makeComment(id: UUID(), message: "message0", date: (date: date.adding(days: -1), string: "1 day ago"), author: "author0")
		let comment1 = makeComment(id: UUID(), message: "message1", date: (date: date.adding(days: -3), string: "3 days ago"), author: "author1")
		let (sut, loader) = makeSUT(currentDate: { date }, locale: .init(identifier: "en_US_POSIX"))

		sut.loadViewIfNeeded()
		loader.completeLoading(with: [comment0.model, comment1.model], at: 0)
		assertThat(sut, isRendering: [comment0.expected, comment1.expected])
		
		sut.simulateUserInitiatedReload()
		loader.completeLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment0.expected, comment1.expected])
	}
	
	func test_loadCommentError_errorViewHidesAfterTapped() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
	
		loader.completeLoadingWithError()
		sut.simulateErrorViewTap()
		
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	// MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, locale: Locale = .current, file: StaticString = #filePath, line: UInt = #line) -> (sut: CommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = CommentUIComposer.commentsComposedWith(loader: loader.loadPublisher, currentDate: currentDate, locale: locale)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Comments"
		let bundle = Bundle(for: CommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class LoaderSpy: CommentLoader {
		
		// MARK: - CommentLoader
		
		private var completions = [(CommentLoader.Result) -> Void]()
		private(set) var cancelCount = 0

		var loadCount: Int {
			return completions.count
		}

		private class Task: CommentsLoaderTask {
			let onCancel: () -> Void

			init(onCancel: @escaping () -> Void) {
				self.onCancel = onCancel
			}

			func cancel() {
				onCancel()
			}
		}

		func load(completion: @escaping (CommentLoader.Result) -> Void) -> CommentsLoaderTask {
			completions.append(completion)
			return Task { [weak self] in
				self?.cancelCount += 1
			}
		}

		func completeLoading(with comments: [Comment] = [], at index: Int = 0) {
			completions[index](.success(comments))
		}

		func completeLoadingWithError(at index: Int = 0) {
			completions[index](.failure(NSError(domain: "loading error", code: 0)))
		}
	}
	
	private struct ExpectedCellContent {
		let username: String
		let message: String
		let date: String
	}
	
	private func makeComment(id: UUID, message: String, date: (date: Date, string: String), author: String) -> (model: Comment, expected: ExpectedCellContent) {
		return (Comment(id: id, message: message, createdAt: date.date, author: Author(username: author)), ExpectedCellContent(username: author, message: message, date: date.string))
	}
	
	private func assertThat(_ sut: CommentsViewController, isRendering comments: [ExpectedCellContent], file: StaticString = #filePath, line: UInt = #line) {
		guard sut.numberOfRenderedCommentViews() == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedCommentViews()) instead.", file: file, line: line)
		}

		comments.enumerated().forEach { index, image in
			assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
		}
	}

	private func assertThat(_ sut: CommentsViewController, hasViewConfiguredFor expected: ExpectedCellContent, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.commentView(at: index)

		guard let cell = view as? CommentCell else {
			return XCTFail("Expected \(CommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.usernameText, expected.username, "username in cell at index \(index)", file: file, line: line)

		XCTAssertEqual(cell.messageText, expected.message, "message in cell at index \(index)", file: file, line: line)

		XCTAssertEqual(cell.dateText, expected.date, "date in cell at index \(index)", file: file, line: line)
	}
}

extension Date {
	fileprivate func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}

extension CommentsViewController {
	fileprivate func simulateErrorViewTap() {
		errorView.hideMessageView()
	}
	
}

//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Cronay on 22.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class ImageCommentsUIIntegrationTests: XCTestCase {

	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}

	func test_loadImageCommentsAction_requestsCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCount, 0)

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCount, 1, "Expected to load when view did load")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 2, "Expected to load when the user initiates a reload")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCount, 3, "Expected to load again when the user initiates a second reload")
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
		let comment0 = makeImageComment(message: "message0", date: (date: date.adding(days: -1), string: "1 day ago"), author: "author0")
		let comment1 = makeImageComment(message: "message1", date: (date: date.adding(days: -2), string: "2 days ago"), author: "author1")
		let comment2 = makeImageComment(message: "message2", date: (date: date.adding(days: -31), string: "1 month ago"), author: "author2")
		let comment3 = makeImageComment(message: "message3", date: (date: date.adding(days: -366), string: "1 year ago"), author: "author3")
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])

		loader.completeLoading(with: [comment0.model], at: 0)
		assertThat(sut, isRendering: [comment0.expectedContent])

		sut.simulateUserInitiatedReload()
		loader.completeLoading(with: [comment0.model, comment1.model, comment2.model, comment3.model], at: 1)
		assertThat(sut, isRendering: [comment0.expectedContent, comment1.expectedContent, comment2.expectedContent, comment3.expectedContent])
	}

	func test_loadCommentsCompletion_rendersErrorMessageOnLoaderFailureUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR"))

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	func test_cancelCommentsLoading_whenViewWillDisappear() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.cancelCount, 0, "Loading should not be cancelled when view just did load")

		sut.viewWillDisappear(false)
		XCTAssertEqual(loader.cancelCount, 1, "Loading should be cancelled when view is about to disappear")
	}

	func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()

		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeLoading()
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	// MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, locale: Locale = .current, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentUIComposer.makeUI(loader: loader.loadPublisher, currentDate: currentDate, locale: locale)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}

	struct ExpectedCellContent {
		let username: String
		let message: String
		let date: String
	}

	private func makeImageComment(message: String, date: (date: Date, string: String), author: String) -> (model: ImageComment, expectedContent: ExpectedCellContent) {
		return (
			ImageComment(id: UUID(), message: message, createdAt: date.date, author: ImageCommentAuthor(username: author)),
			ExpectedCellContent(username: author, message: message, date: date.string)
		)
	}

	func assertThat(_ sut: ImageCommentsViewController, isRendering comments: [ExpectedCellContent], file: StaticString = #filePath, line: UInt = #line) {
		guard sut.numberOfRenderedCommentViews() == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedCommentViews()) instead.", file: file, line: line)
		}

		comments.enumerated().forEach { index, image in
			assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
		}
	}

	func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor expected: ExpectedCellContent, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.commentView(at: index)

		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.usernameText, expected.username, "Expected cell at index \(index) to display \(expected.username), but displays \(String(describing: cell.usernameText)) instead", file: file, line: line)

		XCTAssertEqual(cell.messageText, expected.message, "Expected cell at index \(index) to display \(expected.message), but displays \(String(describing: cell.messageText)) instead", file: file, line: line)

		XCTAssertEqual(cell.dateText, expected.date, "Expected cell at index \(index) to display \(expected.date), but displays \(String(describing: cell.dateText)) instead", file: file, line: line)
	}
}

extension ImageCommentsViewController {
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}

	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}

	private var commentSection: Int {
		return 0
	}

	func numberOfRenderedCommentViews() -> Int {
		tableView.numberOfRows(inSection: commentSection)
	}

	func commentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: commentSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}

	var errorMessage: String? {
		errorView?.message
	}
}

extension ImageCommentCell {
	var usernameText: String? {
		usernameLabel.text
	}

	var messageText: String? {
		messageLabel.text
	}

	var dateText: String? {
		dateLabel.text
	}
}

extension Date {
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}

//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Cronay on 20.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {

	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}

	func test_init_doesNotSendMessageToView() {
		let (_, view) = makeSUT()

		XCTAssertTrue(view.receivedMessages.isEmpty)
	}

	func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()

		sut.didStartLoadingComments()

		XCTAssertEqual(view.receivedMessages, [
			.display(isLoading: true),
			.display(errorMessage: .none)
		])
	}

	func test_didFinishLoadingComments_displaysCommentsAndStopsLoading() {
		let currentDate = Date()
		let (sut, view) = makeSUT(currentDate: { currentDate }, locale: Locale.init(identifier: "en_US_POSIX"))
		let comment0 = imageComment(
			id: UUID(),
			message: "some message",
			date: (date: currentDate.adding(days: -1), string: "1 day ago"),
			author: "some author")
		let comment1 = imageComment(
			id: UUID(),
			message: "another message",
			date: (date: currentDate.adding(days: -31), string: "1 month ago"),
			author: "another author")

		sut.didFinishLoadingComments(with: [comment0.model, comment1.model])

		XCTAssertEqual(view.receivedMessages, [
			.display(isLoading: false),
			.display(presentables: [comment0.presentable, comment1.presentable])
		])
	}

	func test_didFinishLoadingCommentsWithError_displaysErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		let commentsLoadingError = anyNSError()

		sut.didFinishLoadingComments(with: commentsLoadingError)

		XCTAssertEqual(view.receivedMessages, [
			.display(isLoading: false),
			.display(errorMessage: localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR"))
		])
	}

	// MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = { Date() }, locale: Locale = Locale.current, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsPresenter, ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(currentDate: currentDate, locale: locale, loadingView: view, errorView: view, commentsView: view)
		trackForMemoryLeaks(view)
		trackForMemoryLeaks(sut)
		return (sut, view)
	}

	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}

	private class ViewSpy: ImageCommentsLoadingView, ImageCommentsErrorView, ImageCommentsView {

		enum Message: Hashable {
			case display(isLoading: Bool)
			case display(errorMessage: String?)
			case display(presentables: [PresentableImageComment])
		}

		var receivedMessages = Set<Message>()

		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			receivedMessages.insert(.display(isLoading: viewModel.isLoading))
		}

		func display(_ viewModel: ImageCommentsErrorViewModel) {
			receivedMessages.insert(.display(errorMessage: viewModel.message))
		}

		func display(_ viewModel: ImageCommentsViewModel) {
			receivedMessages.insert(.display(presentables: viewModel.presentables))
		}
	}

	private func imageComments() -> (models: [ImageComment], presentables: [PresentableImageComment]) {
		let comment0 = imageComment(id: UUID(), message: "Some message", date: (date: Date(), string: "some time ago"), author: "some author")
		let comment1 = imageComment(id: UUID(), message: "Another message", date: (date: Date(), string: "another time ago"), author: "another authod")

		return (
			[comment0.model, comment1.model],
			[comment0.presentable, comment1.presentable]
		)
	}

	private func imageComment(id: UUID, message: String, date: (date: Date, string: String), author: String) -> (model: ImageComment, presentable: PresentableImageComment) {
		return (
			ImageComment(id: id, message: message, createdAt: date.date, author: ImageCommentAuthor(username: author)),
			PresentableImageComment(username: author, message: message, date: date.string)
		)
	}
}

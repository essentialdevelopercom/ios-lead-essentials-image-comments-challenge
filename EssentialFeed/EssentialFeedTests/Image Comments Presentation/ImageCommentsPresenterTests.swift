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
		let (sut, view) = makeSUT()
		let comments = imageComments()

		sut.didFinishLoadingComments(with: comments)

		XCTAssertEqual(view.receivedMessages, [
			.display(isLoading: false),
			.display(comments: comments)
		])
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsPresenter, ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(loadingView: view, errorView: view, commentsView: view)
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
			case display(comments: [ImageComment])
		}

		var receivedMessages = Set<Message>()

		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			receivedMessages.insert(.display(isLoading: viewModel.isLoading))
		}

		func display(_ viewModel: ImageCommentsErrorViewModel) {
			receivedMessages.insert(.display(errorMessage: viewModel.message))
		}

		func display(_ viewModel: ImageCommentsViewModel) {
			receivedMessages.insert(.display(comments: viewModel.comments))
		}
	}

	private func imageComments() -> [ImageComment] {
		return [
			ImageComment(id: UUID(), message: "Some message", createdAt: Date(), author: ImageCommentAuthor(username: "Some user")),
			ImageComment(id: UUID(), message: "Another message", createdAt: Date(), author: ImageCommentAuthor(username: "Another user"))
		]
	}
}

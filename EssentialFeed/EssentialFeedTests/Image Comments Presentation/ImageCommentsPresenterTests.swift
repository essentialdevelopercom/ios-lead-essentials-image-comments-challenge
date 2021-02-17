//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Raphael Silva on 15/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class ImageCommentsPresenterTests: XCTestCase {

	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}

	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()

		XCTAssertTrue(view.messages.isEmpty)
	}

	func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()

		sut.didStartLoading()

		XCTAssertEqual(view.messages, [.display(errorMessage: nil), .display(isLoading: true)])
	}

	func test_didFinishLoading_displaysCommentsAndStopsLoading() {
		let (sut, view) = makeSUT()

		let comments = uniqueComments()
		sut.didFinishLoading(with: comments)

		XCTAssertEqual(view.messages, [.display(comments: comments), .display(isLoading: false)])
	}

	// MARK: - Helpers

	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (ImageCommentsPresenter, ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(
			commentsView: view,
			loadingView: view,
			errorView: view
		)
		trackForMemoryLeaks(
			sut,
			file: file,
			line: line
		)
		trackForMemoryLeaks(
			view,
			file: file,
			line: line
		)
		return (sut, view)
	}

	private func localized(
		_ key: String,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> String {
		EssentialFeedTests.localized(
			key: key,
			table: "ImageComments",
			bundle: Bundle(
				for: ImageCommentsPresenter.self
			)
		)
	}

	private func uniqueComments() -> [ImageComment] {
		[
			ImageComment(
				id: UUID(),
				message: "a message",
				createdAt: Date(),
				username: "a username"
			),
			ImageComment(
				id: UUID(),
				message: "another message",
				createdAt: Date(),
				username: "another username"
			),
		]
	}

	private class ViewSpy:
		ImageCommentsView,
		ImageCommentsLoadingView,
		ImageCommentsErrorView
	{
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [ImageComment])
		}

		private(set) var messages = Set<Message>()

		func display(isLoading: Bool) {
			messages.insert(
				.display(isLoading: isLoading)
			)
		}

		func display(errorMessage: String?) {
			messages.insert(
				.display(errorMessage: errorMessage)
			)
		}

		func display(comments: [ImageComment]) {
			messages.insert(
				.display(comments: comments)
			)
		}
	}
}

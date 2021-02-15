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
		let view = ViewSpy()
		_ = ImageCommentsPresenter(
			loadingView: view,
			errorView: view
		)

		XCTAssertTrue(view.messages.isEmpty)
	}

	func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(
			loadingView: view,
			errorView: view
		)

		sut.didStartLoading()

		XCTAssertEqual(view.messages, [.display(errorMessage: nil), .display(isLoading: true)])
	}

	// MARK: - Helpers

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

	private class ViewSpy:
		ImageCommentsLoadingView,
		ImageCommentsErrorView
	{
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
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
	}
}

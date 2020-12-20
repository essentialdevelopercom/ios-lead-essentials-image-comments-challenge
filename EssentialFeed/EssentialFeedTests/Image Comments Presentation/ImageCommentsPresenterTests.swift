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
		let view = ViewSpy()
		_ = ImageCommentsPresenter(loadingView: view, errorView: view)

		XCTAssertTrue(view.receivedMessages.isEmpty)
	}

	func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(loadingView: view, errorView: view)

		sut.didStartLoadingComments()

		XCTAssertEqual(view.receivedMessages, [
			.display(isLoading: true),
			.display(errorMessage: .none)
		])
	}

	// MARK: - Helpers

	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}

	private class ViewSpy: ImageCommentsLoadingView, ImageCommentsErrorView {

		enum Message: Hashable {
			case display(isLoading: Bool)
			case display(errorMessage: String?)
		}

		var receivedMessages = Set<Message>()

		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			receivedMessages.insert(.display(isLoading: viewModel.isLoading))
		}

		func display(_ viewModel: ImageCommentsErrorViewModel) {
			receivedMessages.insert(.display(errorMessage: viewModel.message))
		}
	}
}

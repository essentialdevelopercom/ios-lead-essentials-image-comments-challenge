//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sebastian Vidrea on 27.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {

	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_TITLE"))
	}

	func test_init_doesNotSendMessagesToView() {
		let view = ViewSpy()
		_ = ImageCommentsPresenter(imageCommentsView: view, imageCommentsLoadingView: view)

		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
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

	private class ViewSpy: ImageCommentsView, ImageCommentsLoadingView {
		enum Messages: Hashable {
			case display(imageComments: [ImageComment])
			case display(isLoading: Bool)
		}
		private(set) var messages: Set<Messages> = []

		func display(_ viewModel: ImageCommentsViewModel) {
			messages.insert(.display(imageComments: viewModel.imageComments))
		}

		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
	}

}

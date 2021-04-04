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
		let (_, view) = makeSUT()

		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}

	func test_didStartLoadingImageComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()

		sut.didStartLoadingImageComments()

		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}

	func test_didFinishLoadingImageComments_displaysImageCommentsAndStopsLoading() {
		let (sut, view) = makeSUT()
		let imageComments = uniqueImageComments()

		sut.didFinishLoadingImageComments(with: imageComments)

		XCTAssertEqual(view.messages, [
			.display(imageComments: imageComments),
			.display(isLoading: false)
		])
	}

	func test_didFinishLoadingImageCommentsWithError_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()

		sut.didFinishLoadingImageComments(with: anyNSError())

		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("IMAGE_COMMENTS_CONNECTION_ERROR")),
			.display(isLoading: false)
		])
	}

	// MARK: - Helpers

	private func makeSUT() -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(imageCommentsView: view, imageCommentsLoadingView: view, imageCommentsErrorView: view)
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

	private class ViewSpy: ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView {
		enum Messages: Hashable {
			case display(imageComments: [ImageComment])
			case display(isLoading: Bool)
			case display(errorMessage: String?)
		}
		private(set) var messages: Set<Messages> = []

		func display(_ viewModel: ImageCommentsViewModel) {
			messages.insert(.display(imageComments: viewModel.imageComments))
		}

		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}

		func display(_ viewModel: ImageCommentsErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
	}

}

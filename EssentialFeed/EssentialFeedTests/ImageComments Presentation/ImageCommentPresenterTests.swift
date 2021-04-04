//
//  ImageCommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sebastian Vidrea on 04.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class ImageCommentPresenterTests: XCTestCase {

	func test_init_doesNotSentMessagesToView() {
		let (_, view) = makeSUT()

		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}

	func test_shouldDisplayImageComment_displaysImageComment() {
		let (sut, view) = makeSUT()
		let imageComment = uniqueImageComment()

		sut.shouldDisplayImageComment(imageComment)

		let message = view.messages.first
		XCTAssertEqual(view.messages.count, 1)
		XCTAssertEqual(message?.message, imageComment.message)
		XCTAssertEqual(message?.author, imageComment.author.username)
	}

	// MARK: - Helpers

	private func makeSUT() -> (sut: ImageCommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let presenter = ImageCommentPresenter(imageCommentView: view)
		return (presenter, view)
	}

	private class ViewSpy: ImageCommentView {
		private(set) var messages = [ImageCommentViewModel]()

		func display(_ viewModel: ImageCommentViewModel) {
			messages.append(viewModel)
		}
	}

}

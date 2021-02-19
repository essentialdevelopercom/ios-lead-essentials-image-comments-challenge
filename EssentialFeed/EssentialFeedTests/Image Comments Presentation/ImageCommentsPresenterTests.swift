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

	func test_map_createsViewModels() {
		let now = Date()
		let calendar = Calendar(identifier: .gregorian)
		let locale = Locale(identifier: "en_US_POSIX")

		let comments = [
			ImageComment(
				id: UUID(),
				message: "a message",
				createdAt: now.adding(seconds: -30),
				username: "a username"
			),
			ImageComment(
				id: UUID(),
				message: "another message",
				createdAt: now.adding(minutes: -10),
				username: "another username"
			),
			ImageComment(
				id: UUID(),
				message: "yet another message",
				createdAt: now.adding(days: -2),
				username: "yet another username"
			)
		]

		let viewModel = ImageCommentsPresenter.map(
			comments,
			currentDate: now,
			calendar: calendar,
			locale: locale
		)

		XCTAssertEqual(viewModel.comments, [
			ImageCommentViewModel(
				message: "a message",
				date: "30 seconds ago",
				username: "a username"
			),
			ImageCommentViewModel(
				message: "another message",
				date: "10 minutes ago",
				username: "another username"
			),
			ImageCommentViewModel(
				message: "yet another message",
				date: "2 days ago",
				username: "yet another username"
			)
		])
	}

	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()

		XCTAssertTrue(view.messages.isEmpty)
	}

	func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()

		sut.didStartLoading()

		XCTAssertEqual(view.messages, [
			.display(errorMessage: nil),
			.display(isLoading: true)
		])
	}

	func test_didFinishLoading_displaysCommentsAndStopsLoading() {
		let (sut, view) = makeSUT()

		let comments = uniqueComments()
		sut.didFinishLoading(with: comments)

		XCTAssertEqual(view.messages, [
			.display(comments: ImageCommentsPresenter.map(comments).comments),
			.display(isLoading: false)
		])
	}

	func test_didFinishLoadingWithError_displaysErrorAndStopsLoading() {
		let (sut, view) = makeSUT()

		let error = anyNSError()
		sut.didFinishLoading(with: error)

		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR")),
			.display(isLoading: false)
		])
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
			case display(comments: [ImageCommentViewModel])
		}

		private(set) var messages = Set<Message>()

		func display(
			_ viewModel: ImageCommentsLoadingViewModel
		) {
			messages.insert(
				.display(isLoading: viewModel.isLoading)
			)
		}

		func display(
			_ viewModel: ImageCommentsErrorViewModel
		) {
			messages.insert(
				.display(errorMessage: viewModel.message)
			)
		}

		func display(
			_ viewModel: ImageCommentsViewModel
		) {
			messages.insert(
				.display(comments: viewModel.comments)
			)
		}
	}
}

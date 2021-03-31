//
//  FeedImageCommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedImageCommentPresenterTests: XCTestCase {

	func test_title_isLocalized() {
		XCTAssertEqual(FeedImageCommentPresenter.title, localized("FEED_COMMENT_TITLE"))
	}
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}
	
	func test_didFinishLoadingCommentsInEngLocale_displaysFeedAndStopsLoading() {
		let (sut, view) = makeSUT()
		let comments = uniqueComments()
		
		sut.didFinishLoadingComments(with: comments.comments)
		
		XCTAssertEqual(view.messages, [
			.display(comments: comments.presentation),
			.display(isLoading: false)
		])
	}
	
	func test_didFinishLoadingCommentsInRussianLocale_displaysFeedAndStopsLoading() {
		let russianLocale = Locale(identifier: "ru_RU")
		let (sut, view) = makeSUT(locale: russianLocale)
		let comments = uniqueComments(locale: russianLocale)
		
		sut.didFinishLoadingComments(with: comments.comments)
		
		XCTAssertEqual(view.messages, [
			.display(comments: comments.presentation),
			.display(isLoading: false)
		])
	}
	
	func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingComments(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("FEED_COMMENTS_VIEW_ERROR_MESSAGE")),
			.display(isLoading: false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(locale: Locale = Locale(identifier: "en_US_POSIX"), file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageCommentPresenter, view: ViewSpy) {
		let view = ViewSpy()

		let dateFormatter = RelativeDateTimeFormatter()
		dateFormatter.locale = locale

		let sut = FeedImageCommentPresenter(
			commentsView: view,
			errorView: view,
			loadingView: view,
			dateFormatter: dateFormatter,
			currentDateProvider: { Date() }
		)
		
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}

	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Comments"
		let bundle = Bundle(for: FeedImageCommentPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class ViewSpy: FeedImageCommentView, FeedImageCommentLoadingView, FeedImageCommentErrorView {
		
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [PresentationImageComment])
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: FeedImageCommentViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
		
		func display(_ viewModel: FeedImageCommentLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: FeedImageCommentErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
	}
	
}

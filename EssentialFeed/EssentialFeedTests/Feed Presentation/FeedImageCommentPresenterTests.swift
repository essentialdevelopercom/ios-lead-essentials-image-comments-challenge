//
//  FeedImageCommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Danil Vassyakin on 3/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

protocol FeedImageCommentView {
	func display(_ viewModel: FeedImageCommentViewModel)
}

struct FeedImageCommentViewModel {
	let comments: [FeedComment]
}

protocol FeedImageCommentLoadingView {
	func display(_ viewModel: FeedImageCommentLoadingViewModel)
}

struct FeedImageCommentLoadingViewModel {
	let isLoading: Bool
}

protocol FeedImageCommentErrorView {
	func display(_ viewModel: FeedImageCommentErrorViewModel)
}

struct FeedImageCommentErrorViewModel {
	public let message: String?
	
	static var noError: Self {
		Self(message: nil)
	}
	
	static func error(message: String) -> Self {
		Self(message: message)
	}
}

class FeedImageCommentPresenter {
	private let commentsView: FeedImageCommentView
	private let errorView: FeedImageCommentErrorView
	private let loadingView: FeedImageCommentLoadingView
	
	init(commentsView: FeedImageCommentView, errorView: FeedImageCommentErrorView, loadingView: FeedImageCommentLoadingView) {
		self.commentsView = commentsView
		self.errorView = errorView
		self.loadingView = loadingView
	}
	
	static var title: String {
		NSLocalizedString(
			"FEED_COMMENT_TITLE",
			tableName: "Comments",
			bundle: Bundle(for: FeedImageCommentPresenter.self),
			comment: "Title for comments screen")
	}
	
	func didStartLoadingComments() {
		errorView.display(.noError)
		loadingView.display(.init(isLoading: true))
	}
	
}


class FeedImageCommentPresenterTests: XCTestCase {

	func test_title_isLocalized() {
		XCTAssertEqual(FeedImageCommentPresenter.title, localized("FEED_COMMENT_TITLE"))
	}
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageCommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedImageCommentPresenter(commentsView: view, errorView: view, loadingView: view)
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
			case display(comments: [FeedComment])
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

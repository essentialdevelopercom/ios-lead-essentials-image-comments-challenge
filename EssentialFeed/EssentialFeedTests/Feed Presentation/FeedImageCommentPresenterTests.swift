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
	
	private var commentsLoadError: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_ERROR_MESSAGE",
			 tableName: "Comments",
			 bundle: Bundle(for: FeedImageCommentPresenter.self),
			 comment: "Error message displayed when we can't load the image comments from the server")
	}
	
	func didStartLoadingComments() {
		errorView.display(.noError)
		loadingView.display(.init(isLoading: true))
	}
	
	func didFinishLoadingComments(with comments: [FeedComment]) {
		commentsView.display(.init(comments: comments))
		loadingView.display(.init(isLoading: false))
	}
	
	func didFinishLoadingComments(with error: Error) {
		loadingView.display(.init(isLoading: false))
		errorView.display(.error(message: commentsLoadError))
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
	
	func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}
	
	func test_didFinishLoadingComments_displaysFeedAndStopsLoading() {
		let (sut, view) = makeSUT()
		let comments = uniqueComments()
		
		sut.didFinishLoadingComments(with: comments)
		
		XCTAssertEqual(view.messages, [
			.display(comments: comments),
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

func uniqueComment() -> FeedComment {
	.init(id: UUID(),
		  message: "a message",
		  createdAt: Date(),
		  author: .init(username: "danil")
	)
}

func uniqueComments() -> [FeedComment] {
	[uniqueComment(), uniqueComment()]
}

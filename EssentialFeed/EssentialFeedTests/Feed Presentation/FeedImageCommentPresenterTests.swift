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
	func display(_ viewModel: FeedErrorViewModel)
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
	private let loadingView: FeedImageCommentErrorView
	
	init(commentsView: FeedImageCommentView, errorView: FeedImageCommentErrorView, loadingView: FeedImageCommentErrorView) {
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
	
}


class FeedImageCommentPresenterTests: XCTestCase {

	func test_title_isLocalized() {
		XCTAssertEqual(FeedImageCommentPresenter.title, localized("FEED_COMMENT_TITLE"))
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
	
}

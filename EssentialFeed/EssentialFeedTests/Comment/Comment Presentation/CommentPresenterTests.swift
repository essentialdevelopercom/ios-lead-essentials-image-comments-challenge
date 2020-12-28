//
//  CommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CommentPresenterTests: XCTestCase {
	func test_title_isLocalized() {
		XCTAssertEqual(CommentPresenter.title, localized("COMMENT_VIEW_TITLE"))
	}
	
	func test_init_doesNotSentAnyMessageToView() {
		let view = ViewSpy()
		_ = CommentPresenter(loadingView: view, errorView: view)

		XCTAssertTrue(view.messages.isEmpty, "Expected no message upon presenter creation")
	}
	
	func test_didStartLoadingComment_displayNoErrorAndStartLoading() {
		let view = ViewSpy()
		let sut = CommentPresenter(loadingView: view, errorView: view)
		
		sut.didStartLoadingComment()
		
		XCTAssertEqual(view.messages, [.display(errorMessage: nil), .display(isLoading: true)])
	}
	
	// MARK: - Helpers
	
	private class ViewSpy: CommentLoadingView, CommentErrorView {
		var messages = Set<Message>()
		
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
		}
		
		func display(isLoading: Bool) {
			messages.insert(.display(isLoading: isLoading))
		}
		
		func display(errorMessage: String?) {
			messages.insert(.display(errorMessage: errorMessage))
		}
	}
	
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Comment"
		let bundle = Bundle(for: CommentPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}

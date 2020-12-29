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
		let (_, view) = makeSUT()

		XCTAssertTrue(view.messages.isEmpty, "Expected no message upon presenter creation")
	}
	
	func test_didStartLoadingComment_displayNoErrorAndStartLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComment()
		
		XCTAssertEqual(view.messages, [.display(errorMessage: nil), .display(isLoading: true)])
	}
	
	func test_didFinishLoadingCommentWithError_displayErrorAndStopLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingComment(with: anyNSError())
		
		XCTAssertEqual(view.messages, [.display(errorMessage: localized("COMMENT_VIEW_CONNECTION_ERROR")), .display(isLoading: false)])
	}
	
	func test_didFinishLoadingWithComment_displayCommentsAndStopLoading() {
		let (sut, view) = makeSUT()
		let comments = [uniqueComment(), uniqueComment()]
		sut.didFinishLoadingComment(with: comments)
		
		XCTAssertEqual(view.messages, [
			.display(isLoading: false),
			.display(comments)
		])
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = CommentPresenter(loadingView: view, errorView: view, commentView: view)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(view, file: file, line: line)
		
		return (sut, view)
	}
	private class ViewSpy: CommentLoadingView, CommentErrorView, CommentView {
		
		
		var messages = Set<Message>()
		
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(_ comments: [Comment])
		}
		
		func display(_ viewModel: CommentLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: CommentErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: CommentViewModel) {
			messages.insert(.display(viewModel.comments))
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
	
	private func uniqueComment() -> Comment {
		return Comment(id: UUID(),
					   message: "any messages",
					   createAt: Date(),
					   author: CommentAuthor(username: "any user name"))
	}
}

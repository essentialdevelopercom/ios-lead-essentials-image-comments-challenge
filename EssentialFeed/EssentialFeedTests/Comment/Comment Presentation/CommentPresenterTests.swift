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
		let comment0 = makeComment(message: "a messages", createAt: Date(timeIntervalSinceNow: -2), author: "an author")
		let comment1 = makeComment(message: "another messages", createAt: Date(timeIntervalSinceNow: -86400), author: "another author")
		sut.didFinishLoadingComment(with: [comment0.model, comment1.model])
		
		XCTAssertEqual(view.messages, [
			.display(isLoading: false),
			.display([comment0.presentableModel, comment1.presentableModel])
		])
		
		view.messages.forEach { message in
			switch message {
			case let .display(presentableComments):
				validate(presentableComments[0], against: comment0.presentableModel)
				validate(presentableComments[1], against: comment1.presentableModel)
			default: break
			}
		}
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = CommentPresenter(loadingView: view, errorView: view, commentView: view)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(view, file: file, line: line)
		
		return (sut, view)
	}
	
	private func validate(_ receivedComment: PresentableComment, against expectedComment: PresentableComment, file: StaticString = #file, line: UInt = #line) {
		XCTAssertEqual(receivedComment.author, expectedComment.author, file: file, line: line)
		XCTAssertEqual(receivedComment.message, expectedComment.message, file: file, line: line)
		XCTAssertEqual(receivedComment.createAt, expectedComment.createAt, file: file, line: line)
	}
	
	private class ViewSpy: CommentLoadingView, CommentErrorView, CommentView {
		var messages = Set<Message>()
		
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(_ comments: [PresentableComment])
		}
		
		func display(_ viewModel: CommentLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: CommentErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: CommentViewModel) {
			messages.insert(.display(viewModel.presentableComments))
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
	
	private func makeComment(message: String, createAt: Date, author: String) -> (model: Comment, presentableModel: PresentableComment) {
		let id = UUID()
		let model = Comment(id: id, message: message, createAt: createAt, author: CommentAuthor(username: author))
		let presentableModel = makePresentableComment(comment: model)
		return (model, presentableModel)
	}
	
	private func makePresentableComment(comment: Comment) -> PresentableComment {
		return CommentViewModel(comments: [comment]).presentableComments[0]
	}
}

//
//  CommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CommentPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		XCTAssertEqual(CommentsPresenter.title, localized("COMMENTS_VIEW_TITLE"))
	}
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [.display(errorMessage: .none),.display(isLoading: true) ])
	}
	
	func test_didFinishLoadingComments_displaysCommentsAndStopsLoading() {
		let (sut, view) = makeSUT()
		let comments = makeComments()
		
		sut.didFinishLoadingComments(with: comments.models)
		
		XCTAssertEqual(view.messages, [
			.display(comments: comments.presentable),
			.display(isLoading: false)
		])
	}
	
	func test_didFinishLoadingCommentsWithError_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingComments(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("COMMENTS_VIEW_CONNECTION_ERROR")),
			.display(isLoading: false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(
		file: StaticString = #file, line: UInt = #line) -> (sut: CommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = CommentsPresenter(commentView: view, loadingView: view, errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
		let table = "Comments"
		let bundle = Bundle(for: CommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing loclized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class ViewSpy: CommentErrorView, CommentLoadingView, CommentView {
		func display(_ viewModel: CommentViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
		
		func display(_ viewModel: CommentLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: CommentErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [PresentableComment])
			
		}
		private(set) var messages = Set<Message>()
	}
	
	private func makeComments() -> (models: [Comment], presentable: [PresentableComment]) {
		let comment0 = makeComment(id: UUID(), message: "Some message", date: (date: Date(), string: "in 0 seconds"), author: "some author")
		let comment1 = makeComment(id: UUID(), message: "Another message", date: (date: Date(), string: "in 0 seconds"), author: "another author")

		return ([comment0.model, comment1.model], [comment0.presentable, comment1.presentable])
	}

	private func makeComment(id: UUID, message: String, date: (date: Date,string: String), author: String) -> (model: Comment, presentable: PresentableComment) {
		return (Comment(id: id, message: message, createdAt: date.date, author: Author(username: author)), PresentableComment(username: author, message: message, date: date.string))
	}
}

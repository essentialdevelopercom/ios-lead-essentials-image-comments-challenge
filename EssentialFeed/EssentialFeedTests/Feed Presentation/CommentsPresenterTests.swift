//
//  CommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Anton Ilinykh on 11.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class CommentsPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		let (presenter, _) = makeSUT()
		XCTAssertEqual(presenter.title, localized("COMMENTS_VIEW_TITLE"))
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
	
	func test_didFinishLoadingComments_displaysCommentsAndStopsLoading() {
		let (sut, view) = makeSUT()
		let comments = uniqueComments()
		
		sut.didFinishLoadingComments(comments: comments)
		
		let models = [
			CommentViewModel(message:"Some comment", author: "Some author", date: "5 days ago"),
			CommentViewModel(message:"Another comment", author: "Another author", date: "2 weeks ago")
		]
		
		XCTAssertEqual(view.messages, [
			.display(comments: models),
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
	
	//MARK: - Helpers
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: CommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private func makeSUT() -> (CommentsPresenter, ViewSPY) {
		let view = ViewSPY()
		let presenter = CommentsPresenter(errorView: view, loadingView: view, commentsView: view)
		return (presenter, view)
	}
	
	private final class ViewSPY: CommentErrorView, CommentLoadingView, CommentView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [CommentViewModel])
		}
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: CommentErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: CommentLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: CommentListViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
	}
	
	private func uniqueComments() -> [Comment] {
		let now = Date()
		let comment0 = makeItem(message: "Some comment", createdAt: now.adding(days: -5), author: "Some author")
		let comment1 = makeItem(message: "Another comment", createdAt: now.adding(days: -14), author: "Another author")
		return [comment0, comment1]
	}
	
	private func makeItem(id: UUID = UUID(), message: String, createdAt: Date = Date(), author: String ) -> Comment {
		return Comment(id: id, message: message, createdAt: createdAt, author: author)
	}
}

private extension Date {
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}

//
//  CommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Anton Ilinykh on 11.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct CommentLoadingViewModel {
	let isLoading: Bool
}

struct CommentErrorViewModel {
	let message: String?
}

struct CommentViewModel {
	let comments: [Comment]
}

protocol CommentLoadingView {
	func display(_ viewModel: CommentLoadingViewModel)
}

protocol CommentErrorView {
	func display(_ viewModel: CommentErrorViewModel)
}

protocol CommentView {
	func display(_ viewModel: CommentViewModel)
}

final class CommentsPresenter {
	private let errorView: CommentErrorView
	private let loadingView: CommentLoadingView
	private let commentsView: CommentView
	
	private var commentsLoadError: String {
		return NSLocalizedString("COMMENTS_VIEW_CONNECTION_ERROR",
			 tableName: "Feed",
			 bundle: Bundle(for: FeedPresenter.self),
			 comment: "Error message displayed when we can't load the comments from the server")
	}
	
	init(errorView: CommentErrorView, loadingView: CommentLoadingView, commentsView: CommentView) {
		self.errorView = errorView
		self.loadingView = loadingView
		self.commentsView = commentsView
	}
	
	func didStartLoadingComments() {
		errorView.display(CommentErrorViewModel(message: .none))
		loadingView.display(CommentLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingComments(comments: [Comment]) {
		commentsView.display(CommentViewModel(comments: comments))
		loadingView.display(CommentLoadingViewModel(isLoading: false))
	}
	
	func didFinishLoadingComments(with error: Error) {
		errorView.display(CommentErrorViewModel(message: commentsLoadError))
		loadingView.display(CommentLoadingViewModel(isLoading: false))
	}
}

class CommentsPresenterTests: XCTestCase {
	
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
		
		XCTAssertEqual(view.messages, [
			.display(comments: comments),
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
		let table = "Feed"
		let bundle = Bundle(for: FeedPresenter.self)
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
			case display(comments: [Comment])
		}
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: CommentErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: CommentLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		
		func display(_ viewModel: CommentViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
	}
	
	private func uniqueComments() -> [Comment] {
		let comment0 = makeItem(message: "comment0", author: "author0").model
		let comment1 = makeItem(message: "comment1", author: "author1").model
		return [comment0, comment1]
	}
	
	private func makeItem(id: UUID = UUID(), message: String, createdAt: String = "now", author: String ) -> (model: Comment, json: [String: Any]) {
		let model = Comment(id: id, message: message, createdAt: createdAt, author: Comment.Author(username: author))
		let json = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt,
			"author": [
				"username": author
			]
		] as [String : Any]
		return (model: model, json: json)
	}
}

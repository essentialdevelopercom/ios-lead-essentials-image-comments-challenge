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
			CommentViewModel(
				message:"Some comment",
				author: "Some author",
				date: "5 days ago"
			),
			CommentViewModel(
				message:"Another comment",
				author: "Another author",
				date: "2 weeks ago"
			)
		]
		
		XCTAssertEqual(view.messages, [
			.display(comments: models),
			.display(isLoading: false)
		])
	}
	
	func test_map_createsViewModels() {
		let now = Date()
		let calendar = Calendar(identifier: .gregorian)
		let locale = Locale(identifier: "en_US_POSIX")
		
		let comments = [
			makeItem(
				id: UUID(),
				message: "Some comment",
				createdAt: now.adding(days: -6, calendar: calendar),
				author: "Some author"
			),
			makeItem(
				id: UUID(),
				message: "Another comment",
				createdAt: now.adding(days: -25, calendar: calendar),
				author: "Another author"
			),
			makeItem(
				id: UUID(),
				message: "One more comment",
				createdAt: now.adding(days: -32, calendar: calendar),
				author: "One more author"
			)
		]
		
		let viewModel = CommentsPresenter.map(
			comments,
			currentDate: now,
			calendar: calendar,
			locale: locale
		)
		
		XCTAssertEqual(viewModel.comments, [
					   CommentViewModel(
						message:"Some comment",
						   author: "Some author",
						   date: "6 days ago"
					   ),
					   CommentViewModel(
						   message:"Another comment",
						   author: "Another author",
						   date: "3 weeks ago"
					   ),
					   CommentViewModel(
						  message:"One more comment",
						  author: "One more author",
						  date: "1 month ago"
					   )
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
		return [
			makeItem(
				id: UUID(),
				message: "Some comment",
				createdAt: now.adding(days: -5),
				author: "Some author"
			),
			makeItem(
				id: UUID(),
				message: "Another comment",
				createdAt: now.adding(days: -14),
				author: "Another author"
			)
		]
	}
	
	private func makeItem(id: UUID = UUID(), message: String, createdAt: Date = Date(), author: String ) -> Comment {
		return Comment(id: id, message: message, createdAt: createdAt, author: author)
	}
}

private extension Date {
	func adding(days: Int, calendar: Calendar = .current) -> Date {
		return calendar.date(byAdding: .day, value: days, to: self)!
	}
}

//
//  FeedCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ivan Ornes on 10/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedCommentsPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		XCTAssertEqual(FeedImageCommentsPresenter.title, localized("FEED_COMMENTS_VIEW_TITLE"))
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
	
	func test_didFinishLoadingComments_displaysCommentsAndStopsLoading() {
		let locale = Locale(identifier: "en_US_POSIX")
		let (sut, view) = makeSUT(relativeToDate: Date(timeIntervalSince1970: 1617828532), locale: locale)
		
		let coment1 = FeedImageComment(id: UUID(),
									   message: "a message",
									   createdAt: Date(timeIntervalSince1970: 1598627222),
									   author: .init(username: "a username"))
		let viewModel1 = FeedImageCommentViewModel(message: coment1.message,
												  creationDate: "7 months ago",
												  author: coment1.author.username)
		
		let coment2 = FeedImageComment(id: UUID(),
									   message: "another message",
									   createdAt: Date(timeIntervalSince1970: 1608627222),
									   author: .init(username: "another username"))
		let viewModel2 = FeedImageCommentViewModel(message: coment2.message,
												  creationDate: "3 months ago",
												  author: coment2.author.username)
		
		let models = [coment1, coment2]
		let viewModels = [viewModel1, viewModel2]
		sut.didFinishLoadingComments(with: models)
		
		XCTAssertEqual(view.messages, [
			.display(comments: viewModels),
			.display(isLoading: false)
		])
	}
	
	func test_didFinishLoadingCommentsWithError_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingComments(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
			.display(isLoading: false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(relativeToDate: Date = Date(), locale: Locale = .init(identifier: "en_US_POSIX"), file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedImageCommentsPresenter(feedImageCommentsView: view, loadingView: view, errorView: view, referenceDate: relativeToDate, locale: locale)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Feed"
		let bundle = Bundle(for: FeedImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class ViewSpy: FeedImageCommentsView, FeedLoadingView, FeedErrorView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [FeedImageCommentViewModel])
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: FeedErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: FeedLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: FeedImageCommentsViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
	}
}

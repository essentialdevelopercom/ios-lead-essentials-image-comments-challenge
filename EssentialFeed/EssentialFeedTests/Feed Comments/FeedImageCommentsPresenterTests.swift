//
//  FeedImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedImageCommentsPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		XCTAssertEqual(FeedImageCommentsPresenter.title, localized("FEED_COMMENTS_VIEW_TITLE"))
	}
	
	func test_init_doesNotSendMessagesToView() {
		
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingFeed()
		
		XCTAssertEqual(view.messages, [.display(errorMessage: .none),
									   .display(isLoading: true)])
	}
	
	func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
		let (sut, view) = makeSUT()
		let comments = uniqueImageComments()
		
		sut.didFinishLoadingFeed(with: comments)
		
		XCTAssertEqual(view.messages, [.display(comments: comments),
									   .display(isLoading: false)])
	}
	
	func test_didFinishLoadingFeed_displayTheError() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingFeed(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("FEED_COMMENTS_VIEW_ERROR_MESSAGE")),
			.display(isLoading: false)
		])
	}
	
	//MARK: -Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedImageCommentsPresenter(commentsView: view, loadingView: view, errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "FeedImageComments"
		let bundle = Bundle(for: FeedImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private func uniqueImageComments() -> [ImageComment] {
		return [makeCommentItem(id: UUID(), message: "First message", createdAt: Date(), author: "Some Author").item, makeCommentItem().item]
	}
	
	private class ViewSpy: FeedImageCommentsLoadingView, FeedImageCommentsErrorView, FeedImageCommentsView {
		
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [ImageComment])
		}
		
		private(set) var messages = Set<Message>()
		
		func display(isLoading: Bool) {
			messages.insert(.display(isLoading: isLoading))
		}
		
		func display(errorMessage: String?) {
			messages.insert(.display(errorMessage: errorMessage))
		}
		
		func display(comments: [ImageComment]) {
			messages.insert(.display(comments: comments))
		}
	}
	
}

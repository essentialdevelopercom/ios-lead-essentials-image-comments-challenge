//
//  Created by Azamat Valitov on 21.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedCommentsPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		XCTAssertEqual(FeedCommentsPresenter.title, localized("FEED_COMMENTS_VIEW_TITLE"))
	}
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingFeedComments()
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}
	
	func test_didFinishLoadingFeedComments_displaysFeedCommentsAndStopsLoading() {
		let locale = Locale(identifier: "en_US_POSIX")
		let (sut, view) = makeSUT(locale: locale)
		let now = Date()
		let calendar = Calendar(identifier: .gregorian)
		
		let comments = [FeedComment(id: UUID(), message: "any message", date: now.adding(mins: -5, calendar: calendar), authorName: "any name"),
						FeedComment(id: UUID(), message: "another message", date: now.adding(days: -1, calendar: calendar), authorName: "another name")]
		
		sut.didFinishLoadingFeedComments(with: comments)
		
		XCTAssertEqual(view.messages, [
			.display(feedComments: [
				FeedCommentViewModel(name: "any name", message: "any message", formattedDate: "5 minutes ago"),
				FeedCommentViewModel(name: "another name", message: "another message", formattedDate: "1 day ago")
			]),
			.display(isLoading: false)
		])
	}
	
	func test_didFinishLoadingFeedCommentsWithError_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingFeedComments(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("FEED_COMMENTS_VIEW_CONNECTION_ERROR")),
			.display(isLoading: false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(locale: Locale = Locale.current, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedCommentsPresenter(feedCommentsView: view, loadingView: view, errorView: view, locale: locale)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "FeedComments"
		let bundle = Bundle(for: FeedCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class ViewSpy: FeedCommentsView, FeedCommentsLoadingView, FeedCommentsErrorView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(feedComments: [FeedCommentViewModel])
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: FeedCommentsViewModel) {
			messages.insert(.display(feedComments: viewModel.comments))
		}
		
		func display(_ viewModel: FeedCommentsLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: FeedCommentsErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
	}
	
}

private extension Date {
	func adding(days: Int, calendar: Calendar) -> Date {
		return calendar.date(byAdding: .day, value: days, to: self)!
	}
	
	func adding(mins: Int, calendar: Calendar) -> Date {
		return calendar.date(byAdding: .minute, value: mins, to: self)!
	}
}

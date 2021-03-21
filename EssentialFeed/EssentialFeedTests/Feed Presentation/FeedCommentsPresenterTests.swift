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
		let (sut, view) = makeSUT()
		let comments = [uniqueFeedComment(), uniqueFeedComment()]
		
		sut.didFinishLoadingFeedComments(with: comments)
		
		XCTAssertEqual(view.messages, [
			.display(feedComments: comments.toViewModels),
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
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedCommentsPresenter(feedCommentsView: view, loadingView: view, errorView: view)
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
	
	private func uniqueFeedComment() -> FeedComment {
		return FeedComment(id: UUID(), message: "any message", date: Date(), authorName: "any name")
	}
}

private extension Array where Element == FeedComment {
	var toViewModels: [FeedCommentViewModel] {
		map({FeedCommentViewModel(name: $0.authorName, message: $0.message, formattedDate: Self.formatter.localizedString(for: $0.date, relativeTo: Date()))})
	}
	
	private static let formatter = RelativeDateTimeFormatter()
}

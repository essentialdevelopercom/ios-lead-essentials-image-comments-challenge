//
//  Created by Azamat Valitov on 21.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

public protocol FeedCommentsView {
	func display(_ viewModel: FeedCommentsViewModel)
}

public struct FeedCommentsViewModel {
	public let comments: [FeedCommentViewModel]
	
	public init(comments: [FeedCommentViewModel]) {
		self.comments = comments
	}
}

public struct FeedCommentViewModel: Hashable {
	public let name: String
	public let message: String
	public let formattedDate: String
	
	public init(name: String, message: String, formattedDate: String) {
		self.name = name
		self.message = message
		self.formattedDate = formattedDate
	}
}

public protocol FeedCommentsLoadingView {
	func display(_ viewModel: FeedCommentsLoadingViewModel)
}

public struct FeedCommentsLoadingViewModel {
	public let isLoading: Bool
}

public protocol FeedCommentsErrorView {
	func display(_ viewModel: FeedCommentsErrorViewModel)
}

public struct FeedCommentsErrorViewModel {
	public let message: String?
	
	static var noError: FeedCommentsErrorViewModel {
		return FeedCommentsErrorViewModel(message: nil)
	}
	
	public static func error(message: String) -> FeedCommentsErrorViewModel {
		return FeedCommentsErrorViewModel(message: message)
	}
}

class FeedCommentsPresenter {
	
	private let feedCommentsView: FeedCommentsView
	private let loadingView: FeedCommentsLoadingView
	private let errorView: FeedCommentsErrorView
	init(feedCommentsView: FeedCommentsView, loadingView: FeedCommentsLoadingView, errorView: FeedCommentsErrorView) {
		self.feedCommentsView = feedCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public static var title: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_TITLE",
			 tableName: "FeedComments",
			 bundle: Bundle(for: FeedCommentsPresenter.self),
			 comment: "Title for feed comments view")
	}
	
	public func didStartLoadingFeedComments() {
		errorView.display(.noError)
		loadingView.display(FeedCommentsLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingFeedComments(with comments: [FeedComment]) {
		feedCommentsView.display(FeedCommentsViewModel(comments: comments.toViewModels))
		loadingView.display(FeedCommentsLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingFeedComments(with error: Error) {
		errorView.display(.error(message: commentsLoadError))
		loadingView.display(FeedCommentsLoadingViewModel(isLoading: false))
	}
	
	private var commentsLoadError: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_CONNECTION_ERROR",
			 tableName: "FeedComments",
			 bundle: Bundle(for: FeedCommentsPresenter.self),
			 comment: "Error text for comments loading problem")
	}
}

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
	
	func uniqueFeedComment() -> FeedComment {
		return FeedComment(id: UUID(), message: "any message", date: Date(), authorName: "any name")
	}
}

extension Array where Element == FeedComment {
	var toViewModels: [FeedCommentViewModel] {
		map({FeedCommentViewModel(name: $0.authorName, message: $0.message, formattedDate: Self.formatter.localizedString(for: $0.date, relativeTo: Date()))})
	}
	
	private static let formatter = RelativeDateTimeFormatter()
}

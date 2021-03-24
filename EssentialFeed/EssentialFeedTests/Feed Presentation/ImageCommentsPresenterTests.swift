//
// Copyright © 2021 Adrian Szymanowski. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
	
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
	
	func test_didFinishLoadingComments_displaysImageCommentsAndStopsLoading() {
		let comments = uniqueImageComments()
		let configuration = Self.makeTimeFormatConfiguration(date: Date())
		let (sut, view) = makeSUT(timeFormatConfiguration: configuration)
		
		sut.didFinishLoadingComments(with: comments)
		
		XCTAssertEqual(view.messages, [
			.display(comments: ImageCommentsViewModelMapper.map(comments, timeFormatConfiguration: configuration)),
			.display(isLoading: false)
		])
	}
	
	func test_didFinishLoadingComments_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingComments(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR")),
			.display(isLoading: false)
		])
	}
	
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_viewModelMapper_formatImageCommentToViewModel() {
		let fixedRelativeDate = Date()
		let comment1 = ImageComment(
			id: UUID(),
			message: "a message",
			createdAt: fixedRelativeDate.adding(seconds: -60),
			username: "a username"
		)
		
		let comment2 = 	ImageComment(
			id: UUID(),
			message: "some other message",
			createdAt: fixedRelativeDate.adding(seconds: -180),
			username: "some other username"
		)
		
		let configuration = Self.makeTimeFormatConfiguration(date: fixedRelativeDate)
		
		let mappedViewModels = ImageCommentsViewModelMapper.map([comment1, comment2], timeFormatConfiguration: configuration)

		XCTAssertEqual(mappedViewModels, [
			ImageCommentViewModel(
				authorUsername: "a username",
				createdAt: "1 minute ago",
				message: "a message"),
			ImageCommentViewModel(
				authorUsername: "some other username",
				createdAt: "3 minutes ago",
				message: "some other message")
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(timeFormatConfiguration: TimeFormatConfiguration = makeTimeFormatConfiguration(date: Date()), file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(commentsView: view, loadingView: view, errorView: view, timeFormatConfiguration: timeFormatConfiguration)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(view, file: file, line: line)
		return (sut, view)
	}
	
	private static func makeTimeFormatConfiguration(date: Date) -> TimeFormatConfiguration {
		TimeFormatConfiguration(relativeDate: { date }, locale: Locale(identifier: "en_US_POSIX"))
	}
	
	private func uniqueComment(date: Date = Date()) -> ImageComment {
		ImageComment(
			id: UUID(),
			message: "any message",
			createdAt: date,
			username: "any username"
		)
	}
	
	private func uniqueImageComments() -> [ImageComment] {
		[
			uniqueComment(),
			uniqueComment()
		]
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = ImageCommentsPresenter.tableName
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}

	private class ViewSpy: ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView {
		enum Message: Hashable {
			case display(comments: [ImageCommentViewModel])
			case display(errorMessage: String?)
			case display(isLoading: Bool)
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: ImageCommentsViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
		
		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentsErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
	}
	
}

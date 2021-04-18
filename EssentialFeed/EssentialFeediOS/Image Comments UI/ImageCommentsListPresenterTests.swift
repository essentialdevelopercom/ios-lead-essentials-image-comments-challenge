//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 26/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

class ImageCommentsListPresenterTests: XCTestCase {
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty)
	}
	
	func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
	}
	
	func test_didFinishLoadingCommentsWithComments_stopsLoadingAndDisplaysCommentsWithRelativeDateFormatting() {
		let staticDate = Date(timeIntervalSince1970: 1_605_868_247) // "2020-11-20 10:30:47 +0000"
		let (sut, view) = makeSUT(currentDate: { staticDate }, locale: Locale(identifier: "en_US_POSIX"))
		let models = [
			makeModels(timestamp: 1_605_860_313, relativeDate: "2 hours ago"),  // 2020-11-20 08:18:33 +0000
			makeModels(timestamp: 1_605_713_544, relativeDate: "1 day ago"),    // 2020-11-18 15:32:24 +0000
			makeModels(timestamp: 1_604_571_429, relativeDate: "2 weeks ago"),  // 2020-11-05 10:17:09 +0000
			makeModels(timestamp: 1_602_510_149, relativeDate: "1 month ago"),  // 2020-10-12 13:42:29 +0000
			makeModels(timestamp: 1_488_240_000, relativeDate: "3 years ago")   // 2017-02-28 00:00:00 +0000
		]
		
		sut.didFinishLoadingComments(with: models.map(\.comment))
		
		XCTAssertEqual(view.messages, [.display(isLoading: false), .display(comments: models.map(\.viewModel))])
	}
	
	func test_didFinishLoadingFeedWithError_stopsLoadingAndDisplaysLocalizedErrorMessage() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingComments(with: anyNSError())
		
		XCTAssertEqual(view.messages, [.display(isLoading: false), .display(errorMessage: localized("IMAGE_COMMENTS_VIEW_ERROR_MESSAGE"))])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, locale: Locale = Locale.current, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsListPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsListPresenter(
			loadingView: view,
			commentsView: view,
			errorView: view,
			currentDate: currentDate,
			locale: locale
		)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func dateFromTimestamp(_ timestamp: TimeInterval, description: String, file: StaticString = #file, line: UInt = #line) -> Date {
		Date(timeIntervalSince1970: timestamp)
	}
	
	private func makeModels(timestamp: TimeInterval, relativeDate: String) -> (comment: ImageComment, viewModel: ImageCommentViewModel) {
		let model = comment(date: Date(timeIntervalSince1970: timestamp))
		let viewModel = ImageCommentViewModel(author: model.author, message: model.message, creationDate: relativeDate)
		return (model, viewModel)
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsListPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class ViewSpy: ImageCommentsLoadingView, ImageCommentsListView, ImageCommentsErrorView {
		enum Messages: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [ImageCommentViewModel])
		}
		
		private(set) var messages = Set<Messages>()
		
		func display(_ viewModel: ImageCommentsErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentsListViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
	}
}



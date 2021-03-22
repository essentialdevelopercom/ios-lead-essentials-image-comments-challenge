//
//  ImageCommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Eric Garlock on 3/8/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentPresenterTests: XCTestCase {

	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentPresenter.title, localized("COMMENT_VIEW_TITLE"))
	}
	
	func test_init_doesNotSendMessageToView() {
		let (_, view) = makeSUT()
		
		XCTAssert(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [
			.display(message: nil),
			.display(isLoading: true)
		])
	}
	
	func test_didFinishLoadingComments_displaysCommentsAndStopsLoading() {
		let fixedDate = Date()
		let locale = Locale(identifier: "en_US_POSIX")
		let (sut, view) = makeSUT(currentDate: { fixedDate }, locale: locale)
		
		let comments = [
			makeComment(id: UUID(), message: "message0", createdAt: fixedDate.adding(seconds: -30), username: "username0"),
			makeComment(id: UUID(), message: "message1", createdAt: fixedDate.adding(seconds: -30 * 60), username: "username1"),
			makeComment(id: UUID(), message: "message2", createdAt: fixedDate.adding(days: -1), username: "username2"),
			makeComment(id: UUID(), message: "message3", createdAt: fixedDate.adding(days: -2), username: "username3"),
			makeComment(id: UUID(), message: "message4", createdAt: fixedDate.adding(days: -7), username: "username4")
		]
		
		let commentViewModels = [
			ImageCommentViewModel(message: "message0", created: "30 seconds ago", username: "username0"),
			ImageCommentViewModel(message: "message1", created: "30 minutes ago", username: "username1"),
			ImageCommentViewModel(message: "message2", created: "1 day ago", username: "username2"),
			ImageCommentViewModel(message: "message3", created: "2 days ago", username: "username3"),
			ImageCommentViewModel(message: "message4", created: "1 week ago", username: "username4")
		]
		
		sut.didFinishLoadingComments(with: comments)
		
		XCTAssertEqual(view.messages, [
			.display(isLoading: false),
			.display(comments: commentViewModels)
		])
	}
	
	func test_didFinishLoadingCommentsWithError_displaysLocalizedErrorAndStopsLoading() {
		let (sut, view) = makeSUT()
		let error = NSError(domain: "error", code: 0)
		
		sut.didFinishLoadingComments(with: error)
		
		XCTAssertEqual(view.messages, [
			.display(isLoading: false),
			.display(message: localized("COMMENT_VIEW_ERROR_MESSAGE"))
		])
	}
	
	// MARK: - Helpers
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, locale: Locale = .current) -> (sut: ImageCommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentPresenter(commentView: view, loadingView: view, errorView: view, currentDate: currentDate, locale: locale)
		trackForMemoryLeaks(view)
		trackForMemoryLeaks(sut)
		return (sut, view)
	}
	
	private func makeComment(id: UUID, message: String, createdAt: Date, username: String) -> ImageComment {
		return ImageComment(
			id: id,
			message: message,
			createdAt: createdAt,
			author: ImageCommentAuthor(username: username))
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class ViewSpy: ImageCommentView, ImageCommentLoadingView, ImageCommentErrorView {
		
		enum Message: Hashable {
			case display(comments: [ImageCommentViewModel])
			case display(isLoading: Bool)
			case display(message: String?)
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: ImageCommentsViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
		
		func display(_ viewModel: ImageCommentLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentErrorViewModel) {
			messages.insert(.display(message: viewModel.message))
		}
		
	}
	
}

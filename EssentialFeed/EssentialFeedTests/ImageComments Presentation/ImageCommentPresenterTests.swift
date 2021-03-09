//
//  ImageCommentPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Eric Garlock on 3/8/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct ImageCommentViewModel {
	public let comments: [ImageComment]
}

struct ImageCommentLoadingViewModel {
	public let isLoading: Bool
}

struct ImageCommentErrorViewModel {
	public let message: String?
}

protocol ImageCommentView {
	func display(_ viewModel: ImageCommentViewModel)
}

protocol ImageCommentLoadingView {
	func display(_ viewModel: ImageCommentLoadingViewModel)
}

protocol ImageCommentErrorView {
	func display(_ viewModel: ImageCommentErrorViewModel)
}

class ImageCommentPresenter {
	
	public static var title: String {
		return NSLocalizedString("COMMENT_VIEW_TITLE", tableName: "ImageComments", bundle: Bundle(for: ImageCommentPresenter.self), comment: "Title for the comments view")
	}
	
	private let commentView: ImageCommentView
	private let loadingView: ImageCommentLoadingView
	private let errorView: ImageCommentErrorView
	
	public init(commentView: ImageCommentView, loadingView: ImageCommentLoadingView, errorView: ImageCommentErrorView) {
		self.commentView = commentView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public func didStartLoadingComments() {
		errorView.display(ImageCommentErrorViewModel(message: nil))
		loadingView.display(ImageCommentLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingComments(with comments: [ImageComment]) {
		loadingView.display(ImageCommentLoadingViewModel(isLoading: false))
		commentView.display(ImageCommentViewModel(comments: comments))
	}
	
}

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
		let (sut, view) = makeSUT()
		let comment0 = makeComment(id: UUID(), message: "message0", createdAt: Date(), username: "username0")
		let comment1 = makeComment(id: UUID(), message: "message1", createdAt: Date(), username: "username1")
		
		sut.didFinishLoadingComments(with: [comment0, comment1])
		
		XCTAssertEqual(view.messages, [
			.display(isLoading: false),
			.display(comments: [comment0, comment1])
		])
	}
	
	// MARK: - Helpers
	private func makeSUT() -> (sut: ImageCommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentPresenter(commentView: view, loadingView: view, errorView: view)
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
			case display(comments: [ImageComment])
			case display(isLoading: Bool)
			case display(message: String?)
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: ImageCommentViewModel) {
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

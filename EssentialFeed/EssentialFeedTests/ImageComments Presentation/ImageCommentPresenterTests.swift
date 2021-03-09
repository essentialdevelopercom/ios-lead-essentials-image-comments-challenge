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
	
	// MARK: - Helpers
	private func makeSUT() -> (sut: ImageCommentPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentPresenter(commentView: view, loadingView: view, errorView: view)
		trackForMemoryLeaks(view)
		trackForMemoryLeaks(sut)
		return (sut, view)
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
			case display(message: String?)
			case display(isLoading: Bool)
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: ImageCommentViewModel) {
			
		}
		
		func display(_ viewModel: ImageCommentLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentErrorViewModel) {
			messages.insert(.display(message: viewModel.message))
		}
		
	}

}

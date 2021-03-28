//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

protocol ImageCommentsLoadingView {
	func display(isLoading: Bool)
}

protocol ImageCommentsErrorView {
	func display(errorMessage: String?)
}

final class ImageCommentsPresenter {
	private let loadingView: ImageCommentsLoadingView
	private let errorView: ImageCommentsErrorView
	
	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the image comments view")
	}
	
	public init(loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public func didStartLoadingComments() {
		loadingView.display(isLoading: true)
		errorView.display(errorMessage: nil)
	}
}

final class ImageCommentsPresenterTests: XCTestCase {
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingComments_displaysNoErrorMessagesAndStartsLoading() {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(loadingView: view, errorView: view)
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [.display(isLoading: true), .display(errorMessage: nil)])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(loadingView: view, errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class ViewSpy: ImageCommentsLoadingView, ImageCommentsErrorView {
		enum Message: Equatable {
			case display(isLoading: Bool)
			case display(errorMessage: String?)
		}
		
		private(set) var messages = [Message]()
		
		func display(isLoading: Bool) {
			messages.append(.display(isLoading: isLoading))
		}
		
		func display(errorMessage: String?) {
			messages.append(.display(errorMessage: errorMessage))
		}
	}
}

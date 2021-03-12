//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Lukas Bahrle Santana on 22/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingImageComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingImageComments()
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}
	
	func test_didFinishLoadingImageComments_displaysImageCommentsAndStopsLoading() {
		let fixedDate = Date(timeIntervalSince1970: 0).adding(days: 5)
	
		let (sut, view) = makeSUT(currentDate: {fixedDate}, locale: Locale(identifier: "en_US"))
		
		let imageComments = [
			ImageComment(id: UUID(), message: "m1", createdAt: fixedDate.adding(seconds: -30), author: ImageCommentAuthor(username: "a1")),
			ImageComment(id: UUID(), message: "m2", createdAt: fixedDate.adding(seconds: -30 * 60), author: ImageCommentAuthor(username: "a2")),
			ImageComment(id: UUID(), message: "m3", createdAt: fixedDate.adding(days: -1), author: ImageCommentAuthor(username: "a3")),
			ImageComment(id: UUID(), message: "m4", createdAt: fixedDate.adding(days: -2), author: ImageCommentAuthor(username: "a4")),
			ImageComment(id: UUID(), message: "m5", createdAt: fixedDate.adding(days: -7), author: ImageCommentAuthor(username: "a5"))
		]
		
		let presentableImageComments = [
			PresentableImageComment(message: "m1", createdAt: "30 seconds ago", username: "a1"),
			PresentableImageComment(message: "m2", createdAt: "30 minutes ago", username: "a2"),
			PresentableImageComment(message: "m3", createdAt: "1 day ago", username: "a3"),
			PresentableImageComment(message: "m4", createdAt: "2 days ago", username: "a4"),
			PresentableImageComment(message: "m5", createdAt: "1 week ago", username: "a5")
		]
		
		sut.didFinishLoadingImageComments(with: imageComments)
		
		XCTAssertEqual(view.messages, [
			.display(isLoading: false),
			.display(imageComments: presentableImageComments)
		])
	}
	
	func test_didFinishLoadingImageCommentsdWithError_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingImageComments(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR")),
			.display(isLoading: false)
		])
	}
	
	
	// MARK: - Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init, locale: Locale = .current, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(imageCommentsView: view, loadingView: view, errorView: view, currentDate: currentDate, locale: locale)
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
}


private class ViewSpy: ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView{
	enum Message: Hashable {
		case display(errorMessage: String?)
		case display(isLoading: Bool)
		case display(imageComments: [PresentableImageComment])
	}
	
	private(set) var messages = Set<Message>()
	
	func display(_ viewModel: ImageCommentsLoadingViewModel) {
		messages.insert(.display(isLoading: viewModel.isLoading))
	}
	
	func display(_ viewModel: ImageCommentsErrorViewModel) {
		messages.insert(.display(errorMessage: viewModel.message))
	}
	
	func display(_ viewModel: ImageCommentsViewModel) {
		messages.insert(.display(imageComments: viewModel.imageComments))
	}
}

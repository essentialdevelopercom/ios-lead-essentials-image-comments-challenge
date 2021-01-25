//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Lukas Bahrle Santana on 22/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed


private class ViewSpy: ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView{
	
	enum Message: Hashable {
		case display(errorMessage: String?)
		case display(isLoading: Bool)
		case display(imageComments: [ImageComment])
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



class ImageCommentsPresenterTests: XCTestCase{
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
		let (sut, view) = makeSUT()
		let imageComments = uniqueImageComments()
		
		sut.didFinishLoadingImageComments(with: imageComments)
		
		XCTAssertEqual(view.messages, [
			.display(isLoading: false),
			.display(imageComments: imageComments)
		])
	}
	
	
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(imageCommentsView: view, loadingView: view, errorView: view)
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
	
	func uniqueImageComment() -> ImageComment {
		return ImageComment(id: UUID(), message: "any", createdAt: Date(), author: ImageCommentAuthor(username: "any-username"))
	}

	func uniqueImageComments() -> [ImageComment] {
		return ([uniqueImageComment(), uniqueImageComment()])
	}
}

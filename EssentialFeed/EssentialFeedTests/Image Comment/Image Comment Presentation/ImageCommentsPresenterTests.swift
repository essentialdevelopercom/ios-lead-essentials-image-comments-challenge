//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 03/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
	
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}

	func test_init_doesNotSendMessageToView() {
		let (_, view) = makeSUT()
		
		XCTAssertEqual(view.receivedMessages.isEmpty, true)
	}
	
	func test_didStartLoadingImageComments_startsLoadingAndDisplaysNoError() {
		let (sut, view) = makeSUT()

		sut.didStartLoadingImageComments()
		
		XCTAssertEqual(view.receivedMessages, [.display(isLoading: true), .display(errorMessage: nil)])
	}
	
	func test_didFinishLoadingImageComments_stopsLoadingAndDisplaysImageComments() {
		let date = Date()
		let (sut, view) = makeSUT()
		let comment1 = makeComment(message: "a message", date: (date: date.adding(days: -1), string: "1 day ago"), author: "author")
		let comment2 = makeComment(message: "another message", date: (date: date.adding(days: -2), string: "2 days ago"), author: "author")

		sut.didFinishLoadingImageComments(with: [comment1.model, comment2.model])
		
		XCTAssertEqual(view.receivedMessages, [.display(isLoading: false), .display(comments: [comment1.presentableComment, comment2.presentableComment])])
	}
	
	func test_didFinishLoadingImageCommentsWithError_stopsLoadingAndDisplaysError() {
		let (sut, view) = makeSUT()
		let errorMessage = localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR")

		sut.didFinishLoadingImageComments(with: NSError())
		
		XCTAssertEqual(view.receivedMessages, [.display(isLoading: false), .display(errorMessage: errorMessage)])
	}
	
	//MARK: Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(imageCommentsView: view, loadingView: view, errorView: view)
		
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		return (sut, view)
	}
	
	private func makeComment(message: String, date: (date: Date, string: String), author: String) -> (model: ImageComment, presentableComment: PresentableImageComment) {
		return (
			ImageComment(id: UUID(), message: message, createdDate: date.date, author: CommentAuthor(username: author)),
			PresentableImageComment(username: author, message: message, date: date.string)
		)
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
	
	class ViewSpy: ImageCommentsLoadingView, ImageCommentsErrorView, ImageCommentsView {
		enum Message: Equatable {
			case display(isLoading: Bool)
			case display(errorMessage: String?)
			case display(comments: [PresentableImageComment])
		}
		var receivedMessages = [Message]()
		
		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			receivedMessages.append(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentsErrorViewModel) {
			receivedMessages.append(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: ImageCommentsViewModel) {
			receivedMessages.append(.display(comments: viewModel.comments))
		}
	}
}

private extension Date {
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}

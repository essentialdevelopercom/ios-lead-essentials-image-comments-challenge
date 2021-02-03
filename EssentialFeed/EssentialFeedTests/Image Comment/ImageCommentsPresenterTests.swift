//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 03/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct ImageCommentsLoadingViewModel {
	let isLoading: Bool
}

protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

struct ImageCommentsErrorViewModel {
	let message: String?
}

protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

struct ImageCommentsViewModel {
	let comments: [ImageComment]
}

protocol ImageCommentsView {
	func display(_ viewModel: ImageCommentsViewModel)
}

class ImageCommentsPresenter {
	let loadingView: ImageCommentsLoadingView
	let errorView: ImageCommentsErrorView
	let imageCommentsView: ImageCommentsView
	
	init(imageCommentsView: ImageCommentsView, loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
		self.imageCommentsView = imageCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	func didStartLoadingImageComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentsErrorViewModel(message: nil))
	}
	
	func didFinishLoadingImageComments(with comments: [ImageComment]) {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
		imageCommentsView.display(ImageCommentsViewModel(comments: comments))
	}
}

class ImageCommentsPresenterTests: XCTestCase {

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
		let (sut, view) = makeSUT()
		let comment = makeComment(id: UUID(), message: "a message", created_at: Date(), username: "user")

		sut.didFinishLoadingImageComments(with: [comment, comment])
		
		XCTAssertEqual(view.receivedMessages, [.display(isLoading: false), .display(comments: [comment, comment])])
	}
	
	//MARK: Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(imageCommentsView: view, loadingView: view, errorView: view)
		
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		return (sut, view)
	}
	
	private func makeComment(id: UUID, message: String, created_at: Date, username: String) -> ImageComment {
		let author = CommentAuthor(username: username)
		let comment = ImageComment(id: id, message: message, createdDate: created_at, author: author)
		
		return comment
	}
	
	class ViewSpy: ImageCommentsLoadingView, ImageCommentsErrorView, ImageCommentsView {
		enum Message: Equatable {
			case display(isLoading: Bool)
			case display(errorMessage: String?)
			case display(comments: [ImageComment])
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

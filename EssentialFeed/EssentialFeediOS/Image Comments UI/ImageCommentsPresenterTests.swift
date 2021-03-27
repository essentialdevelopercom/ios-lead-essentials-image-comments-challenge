//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 26/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

struct ImageCommentsLoadingViewModel {
	let isLoading: Bool
}

struct ImageCommentsListViewModel {
	let comments: [ImageComment]
}

struct ImageCommentsErrorViewModel {
	let message: String?
}

protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

protocol ImageCommentsListView {
	func display(_ viewModel: ImageCommentsListViewModel)
}

protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

final class ImageCommentsListPresenter {
	
	private let loadingView: ImageCommentsLoadingView
	private let commentsView: ImageCommentsListView
	private let errorView: ImageCommentsErrorView
	
	init(loadingView: ImageCommentsLoadingView, commentsView: ImageCommentsListView, errorView: ImageCommentsErrorView) {
		self.loadingView = loadingView
		self.commentsView = commentsView
		self.errorView = errorView
	}
	
	func didStartLoadingComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentsErrorViewModel(message: nil))
	}
	
	func didFinishLoadingComments(with comments: [ImageComment]) {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
		commentsView.display(ImageCommentsListViewModel(comments: comments))
	}
}

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
	
	func test_didFinishLoadingCommentsWithComments_stopsLoadingAndDisplaysComments() {
		let (sut, view) = makeSUT()
		let comments = makeComments()
		
		sut.didFinishLoadingComments(with: comments)
		
		XCTAssertEqual(view.messages, [.display(isLoading: false), .display(comments: comments)])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsListPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsListPresenter(loadingView: view, commentsView: view, errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private func makeComment() -> ImageComment {
		ImageComment(
			id: UUID(),
			message: "any message",
			creationDate: Date(),
			author: "any author"
		)
	}
	
	func makeComments() -> [ImageComment] {
		return [makeComment(), makeComment()]
	}
	
	private class ViewSpy: ImageCommentsLoadingView, ImageCommentsListView, ImageCommentsErrorView {
		
		enum Messages: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
			case display(comments: [ImageComment])
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



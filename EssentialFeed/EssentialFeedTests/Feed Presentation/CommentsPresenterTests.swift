//
//  CommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Anton Ilinykh on 11.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

struct CommentLoadingViewModel {
	let isLoading: Bool
}

struct CommentErrorViewModel {
	let message: String?
}

protocol CommentLoadingView {
	func display(_ viewModel: CommentLoadingViewModel)
}

protocol CommentErrorView {
	func display(_ viewModel: CommentErrorViewModel)
}

final class CommentsPresenter {
	private let errorView: CommentErrorView
	private let loadingView: CommentLoadingView
	
	init(errorView: CommentErrorView, loadingView: CommentLoadingView) {
		self.errorView = errorView
		self.loadingView = loadingView
	}
	
	func didStartLoadingComments() {
		errorView.display(CommentErrorViewModel(message: .none))
		loadingView.display(CommentLoadingViewModel(isLoading: true))
	}
}

class CommentsPresenterTests: XCTestCase {
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}
	
	//MARK: - Helpers
	
	private func makeSUT() -> (CommentsPresenter, ViewSPY) {
		let view = ViewSPY()
		let presenter = CommentsPresenter(errorView: view, loadingView: view)
		return (presenter, view)
	}
	
	private final class ViewSPY: CommentErrorView, CommentLoadingView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
		}
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: CommentErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
		
		func display(_ viewModel: CommentLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
	}
}

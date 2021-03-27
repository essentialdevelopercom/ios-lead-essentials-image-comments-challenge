//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 26/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

struct ImageCommentsLoadingViewModel {
	let isLoading: Bool
}

struct ImageCommentsErrorViewModel {
	let message: String?
}

protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

final class ImageCommentsListPresenter {
	
	private let loadingView: ImageCommentsLoadingView
	private let errorView: ImageCommentsErrorView
	
	init(loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	func didStartLoadingComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentsErrorViewModel(message: nil))
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
		
		XCTAssertEqual(view.messages, [.display(isLoading: true), .display(errorMessage: .none)])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsListPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsListPresenter(loadingView: view, errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private class ViewSpy: ImageCommentsLoadingView, ImageCommentsErrorView {
		
		enum Messages: Equatable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
		}
		
		private(set) var messages = [Messages]()
		
		func display(_ viewModel: ImageCommentsErrorViewModel) {
			messages.append(.display(errorMessage: viewModel.message))
		}
		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			messages.append(.display(isLoading: viewModel.isLoading))
		}
	}
}



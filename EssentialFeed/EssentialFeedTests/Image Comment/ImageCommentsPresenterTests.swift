//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alok Subedi on 03/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

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

class ImageCommentsPresenter {
	let loadingView: ImageCommentsLoadingView
	let errorView: ImageCommentsErrorView
	init(loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	func didStartLoadingImageComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentsErrorViewModel(message: nil))
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
	
	//MARK: Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(loadingView: view, errorView: view)
		
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		return (sut, view)
	}
	
	class ViewSpy: ImageCommentsLoadingView, ImageCommentsErrorView {
		enum Message: Equatable {
			case display(isLoading: Bool)
			case display(errorMessage: String?)
		}
		var receivedMessages = [Message]()
		
		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			receivedMessages.append(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentsErrorViewModel) {
			receivedMessages.append(.display(errorMessage: viewModel.message))
		}
	}
}

//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ángel Vázquez on 26/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

struct ImageCommentsErrorViewModel {
	let message: String?
}

protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

final class ImageCommentsListPresenter {
	
	private let errorView: ImageCommentsErrorView
	
	init(errorView: ImageCommentsErrorView) {
		self.errorView = errorView
	}
	
	func didStartLoadingComments() {
		errorView.display(ImageCommentsErrorViewModel(message: nil))
	}
}

class ImageCommentsListPresenterTests: XCTestCase {
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty)
	}
	
	func test_didStartLoadingComments_displaysNoErrorMessage() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingComments()
		
		XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsListPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsListPresenter(errorView: view)
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, view)
	}
	
	private class ViewSpy: ImageCommentsErrorView {
		
		enum Messages: Equatable {
			case display(errorMessage: String?)
		}
		
		private(set) var messages = [Messages]()
		
		func display(_ viewModel: ImageCommentsErrorViewModel) {
			messages.append(.display(errorMessage: viewModel.message))
		}
	}
}



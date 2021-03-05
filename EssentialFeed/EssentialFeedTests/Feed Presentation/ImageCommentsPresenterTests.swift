//
// Copyright © 2021 Adrian Szymanowski. All rights reserved.
//

import XCTest

struct ImageCommentsLoadingViewModel {}
protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

struct ImageCommentsErrorViewModel {}
protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

class ImageCommentsPresenter {
	private let loadingView: ImageCommentsLoadingView
	private let errorView: ImageCommentsErrorView
	
	init(loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	func didStartLoadingComments() {
		errorView.display(.init())
		loadingView.display(.init())
	}
}

class ImageCommentsPresenterTests: XCTestCase {
	
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
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(loadingView: view, errorView: view)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(view, file: file, line: line)
		return (sut, view)
	}

	private class ViewSpy: ImageCommentsLoadingView, ImageCommentsErrorView {
		enum Message: Hashable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			messages.insert(.display(isLoading: true))
		}
		
		func display(_ viewModel: ImageCommentsErrorViewModel) {
			messages.insert(.display(errorMessage: .none))
		}
	}
	
}

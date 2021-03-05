//
// Copyright © 2021 Adrian Szymanowski. All rights reserved.
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
	private let commentsView: ImageCommentsView
	private let loadingView: ImageCommentsLoadingView
	private let errorView: ImageCommentsErrorView
	
	init(commentsView: ImageCommentsView, loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
		self.commentsView = commentsView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	func didStartLoadingComments() {
		errorView.display(ImageCommentsErrorViewModel(message: .none))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingComments(with comments: [ImageComment]) {
		commentsView.display(ImageCommentsViewModel(comments: comments))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
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
	
	func test_didFinishLoadingComments_displaysImageCommentsAndStopsLoading() {
		let (sut, view) = makeSUT()
		let comments = uniqueImageComments()
		
		sut.didFinishLoadingComments(with: comments)
		
		XCTAssertEqual(view.messages, [
			.display(comments: comments),
			.display(isLoading: false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = ImageCommentsPresenter(commentsView: view, loadingView: view, errorView: view)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(view, file: file, line: line)
		return (sut, view)
	}
	
	private func uniqueComment() -> ImageComment {
		ImageComment(
			id: UUID(),
			message: "",
			createdAt: Date(),
			author: ImageComment.Author(username: "")
		)
	}
	
	private func uniqueImageComments() -> [ImageComment] {
		[
			uniqueComment(),
			uniqueComment()
		]
	}

	private class ViewSpy: ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView {
		enum Message: Hashable {
			case display(comments: [ImageComment])
			case display(errorMessage: String?)
			case display(isLoading: Bool)
		}
		
		private(set) var messages = Set<Message>()
		
		func display(_ viewModel: ImageCommentsViewModel) {
			messages.insert(.display(comments: viewModel.comments))
		}
		
		func display(_ viewModel: ImageCommentsLoadingViewModel) {
			messages.insert(.display(isLoading: viewModel.isLoading))
		}
		
		func display(_ viewModel: ImageCommentsErrorViewModel) {
			messages.insert(.display(errorMessage: viewModel.message))
		}
	}
	
}

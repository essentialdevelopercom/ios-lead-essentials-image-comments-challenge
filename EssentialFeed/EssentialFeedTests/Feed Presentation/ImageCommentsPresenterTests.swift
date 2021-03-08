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
	
	private var imageCommentsLoadError: String {
		"Some error"
	}
	
	func didStartLoadingComments() {
		errorView.display(ImageCommentsErrorViewModel(message: .none))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingComments(with comments: [ImageComment]) {
		commentsView.display(ImageCommentsViewModel(comments: comments))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	func didFinishLoadingFeed(with error: Error) {
		errorView.display(ImageCommentsErrorViewModel(message: imageCommentsLoadError))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the image comments view")
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
	
	func test_didFinishLoadingComments_displaysLocalizedErrorMessageAndStopsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingFeed(with: anyNSError())
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: "Some error"),
			.display(isLoading: false)
		])
	}
	
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
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
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
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

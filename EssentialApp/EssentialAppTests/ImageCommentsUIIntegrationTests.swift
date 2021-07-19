//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS
import Combine

class ImageCommentsUIIntegrationTests: XCTestCase {
	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, imageCommentsTitle)
	}

	func test_loadActions_requestFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 0, "Expected no loading requests before view is loaded")

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 1, "Expected a loading request once view is loaded")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 2, "Expected another loading request once user initiates a reload")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}

	func test_loadingImageCommentsIndicator_isVisibleWhileLoadingImageComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

		loader.completeImageCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

		loader.completeImageCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	}

	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedImageComments() {
		let comment0 = makeComment(message: "a message", username: "a username")
		let comment1 = makeComment(message: "another message", username: "another username")
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		let emptyComments: [ImageComment] = []
		assertThat(sut, isRendering: emptyComments)

		loader.completeImageCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])

		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoading(with: [comment0, comment1], at: 1)
		assertThat(sut, isRendering: [comment0, comment1])
	}

	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedEmptyImageCommentsAfterNonEmptyImageComments() {
		let comment0 = makeComment(message: "a message", username: "a username")
		let comment1 = makeComment(message: "another message", username: "another username")
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment0, comment1], at: 0)
		assertThat(sut, isRendering: [comment0, comment1])

		sut.simulateUserInitiatedReload()
		let emptyComments: [ImageComment] = []
		loader.completeImageCommentsLoading(with: emptyComments, at: 1)
		assertThat(sut, isRendering: emptyComments)
	}

	func test_loadImageCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment0 = makeComment(message: "a message", username: "a username")
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])

		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment0])
	}

	func test_loadImageCommentsCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()

		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeImageCommentsLoading(at: 0)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	func test_loadImageCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeImageCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	func test_tapOnErrorView_hidesErrorMessage() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeImageCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)

		sut.simulateErrorViewTap()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	func test_deallocation_cancelsImageCommentsRequests() {
		var sut: ListViewController?

		var cancelCallCount = 0

		autoreleasepool {
			sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: {
				PassthroughSubject<[ImageComment], Error>()
					.handleEvents(receiveCancel: {
						cancelCallCount += 1
					})
					.eraseToAnyPublisher()
			})
			sut?.loadViewIfNeeded()
		}

		XCTAssertEqual(cancelCallCount, 0)

		sut = nil

		XCTAssertEqual(cancelCallCount, 1)
	}

	// MARK: - Helpers

	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: ListViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader.loadPublisher)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	private func makeComment(message: String, username: String) -> ImageComment {
		ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
	}

	func assertThat(_ sut: ListViewController, isRendering imageComments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()

		guard sut.numberOfRenderedImageCommentsImageViews() == imageComments.count else {
			return XCTFail("Expected \(imageComments.count) images, got \(sut.numberOfRenderedImageCommentsImageViews()) instead.", file: file, line: line)
		}

		let viewModels = ImageCommentsPresenter.map(imageComments)

		viewModels.comments.enumerated().forEach { index, comment in
			assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
		}

		executeRunLoopToCleanUpReferences()
	}

	func assertThat(_ sut: ListViewController, hasViewConfiguredFor comment: ImageCommentViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)

		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.usernameText, comment.username, "Expected username text to be \(comment.username)) for comment view at index (\(index))", file: file, line: line)

		XCTAssertEqual(cell.messageText, comment.message, "Expected message text to be \(comment.message)) for comment view at index (\(index))", file: file, line: line)

		XCTAssertEqual(cell.dateText, comment.createdAt, "Expected date text to be \(comment.createdAt)) for comment view at index (\(index))", file: file, line: line)
	}

	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}

	private class LoaderSpy {
		private var imageCommentsRequests = [PassthroughSubject<[ImageComment], Error>]()

		var loadImageCommentsCallCount: Int {
			return imageCommentsRequests.count
		}

		func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
			let publisher = PassthroughSubject<[ImageComment], Error>()
			imageCommentsRequests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}

		func completeImageCommentsLoading(with imageComments: [ImageComment] = [], at index: Int = 0) {
			imageCommentsRequests[index].send(imageComments)
		}

		func completeImageCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			imageCommentsRequests[index].send(completion: .failure(error))
		}
	}
}

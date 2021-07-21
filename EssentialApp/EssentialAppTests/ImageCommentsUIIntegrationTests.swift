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

		XCTAssertEqual(sut.title, ImageCommentsPresenter.title)
	}

	func test_imageCommentsActions_requestImageCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.imageCommentsCallCount, 0, "Expected no loading requests before view is loaded")

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.imageCommentsCallCount, 1, "Expected a loading request once view is loaded")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.imageCommentsCallCount, 2, "Expected another loading request once user initiates a reload")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.imageCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}

	func test_loadingImageCommentsIndicator_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

		loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

		loader.completeCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	}

	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let imageComment0 = makeComment(message: "first message", authorUserName: "first username")
		let imageComment1 = makeComment(message: "second message", authorUserName: "second username")
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])

		loader.completeCommentsLoading(with: [imageComment0], at: 0)
		assertThat(sut, isRendering: [imageComment0])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [imageComment0, imageComment1], at: 1)
		assertThat(sut, isRendering: [imageComment0, imageComment1])
	}

	func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
		let imageComment0 = makeComment(message: "first message", authorUserName: "first username")
		let imageComment1 = makeComment(message: "second message", authorUserName: "second username")
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [imageComment0, imageComment1], at: 0)
		assertThat(sut, isRendering: [imageComment0, imageComment1])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}

	func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let imageComment0 = makeComment(message: "first message", authorUserName: "first username")
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [imageComment0], at: 0)
		assertThat(sut, isRendering: [imageComment0])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [imageComment0])
	}

	func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()

		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeCommentsLoading(at: 0)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	func test_tapOnErrorView_hidesErrorMessage() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)

		sut.simulateErrorViewTap()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	func test_deinit_cancelCommentsLoading() {
		var cancelCallCount = 0

		var sut: ListViewController?
		autoreleasepool {
			sut = ImageCommentsUIComposer.imageCommentsComposedWith(imageCommentsLoader: {
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
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(imageCommentsLoader: loader.loadPublisher)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	private func makeComment(id: UUID = UUID(), message: String = "any message", authorUserName: String = "any username") -> ImageComment {
		return ImageComment(id: id, message: message, createdAt: Date(), authorUserName: authorUserName)
	}
}

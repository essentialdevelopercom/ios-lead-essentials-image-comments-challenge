//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS
import Combine

class ImageCommentsUIIntegrationTests: XCTestCase {
	func test_commentsView_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, commentsTitle)
	}

	func test_loadCommentsActions_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a reload")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}

	func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
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
		let comment0 = makeComment(message: "a message", username: "a user")
		let comment1 = makeComment(message: "another message", username: "another user")
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [], currentDate: Date())

		loader.completeCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0], currentDate: Date())

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
		assertThat(sut, isRendering: [comment0, comment1], currentDate: Date())
	}

	func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
		let comment = makeComment()
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment], at: 0)
		assertThat(sut, isRendering: [comment], currentDate: Date())

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [], currentDate: Date())
	}

	func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment = makeComment()
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment], at: 0)
		assertThat(sut, isRendering: [comment], currentDate: Date())

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment], currentDate: Date())
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

	func test_deinit_cancelRequest() {
		var cancelCallCount = 0
		var sut: ListViewController?

		autoreleasepool {
			sut = ImageCommentsUIComposer.commentsComposedWith(commentsLoader: {
				PassthroughSubject<[ImageComment], Error>()
					.handleEvents(receiveCancel: {
						cancelCallCount += 1
					}).eraseToAnyPublisher()
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
		let sut = ImageCommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	private func makeComment(message: String = "any message",
	                         username: String = "any username"
	) -> ImageComment {
		ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
	}
}

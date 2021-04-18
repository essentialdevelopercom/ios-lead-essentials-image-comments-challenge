//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialApp
import EssentialFeed
import EssentialFeediOS
import Combine

final class ImageCommentsUIIntegrationTests: XCTestCase {
	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, imageCommentsTitle)
	}

	func test_loadImageCommentsActions_requestImageCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a load")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
	}

	func test_loadingImageCommentsIndicator_isVisibleWhileLoadingImageComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")

		loader.completeImageCommentsLoading(at: 0)
		XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading is completed successfully")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user initiates a reload")

		loader.completeImageCommentsLoadingWithError(at: 1)
		XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once user initiated loading completed with error")
	}

	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedImageComments() {
		let imageComment0 = makeImageComment(message: "a message", username: "a user", createdAt: Date())
		let imageComment1 = makeImageComment(message: "another message", username: "another user", createdAt: Date())
		let imageComment2 = makeImageComment(message: "yet another message", username: "yet another user", createdAt: Date())
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [ImageComment]())

		loader.completeImageCommentsLoading(with: [imageComment0], at: 0)
		assertThat(sut, isRendering: [imageComment0])

		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoading(with: [imageComment0, imageComment1, imageComment2], at: 1)
		assertThat(sut, isRendering: [imageComment0, imageComment1, imageComment2])
	}

	func test_loadImageCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let imageComment0 = makeImageComment(message: "a message", username: "a user", createdAt: Date())
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [imageComment0], at: 0)
		assertThat(sut, isRendering: [imageComment0])

		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [imageComment0])
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

	func test_loadImageCommentsCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()

		let exp = expectation(description: "Wait for backgorund queue")
		DispatchQueue.global().async {
			loader.completeImageCommentsLoading()
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	func test_deinit_cancelsRunningRequest() {
		var cancelCallCount = 0

		var sut: ListViewController?

		autoreleasepool {
			sut = ImageCommentsUIComposer.imageCommentsComposedWith(imageCommentsLoader: {
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

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(imageCommentsLoader: loader.loadPublisher)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	private func makeImageComment(message: String = "a message", username: String = "a user", createdAt: Date = Date()) -> ImageComment {
		ImageComment(id: UUID(), message: message, createdAt: createdAt, username: username)
	}
}

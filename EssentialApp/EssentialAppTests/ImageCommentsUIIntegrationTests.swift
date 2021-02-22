//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Raphael Silva on 20/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Combine
import EssentialApp
import EssentialFeed
import EssentialFeediOS
import XCTest

final class ImageCommentsUIIntegrationTests: XCTestCase {
	
	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, ImageCommentsPresenter.title)
	}

	func test_loadAction_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(
			loader.loadCommentsCallCount,
			0,
			"Expected no loading requests before view is loaded"
		)

		sut.loadViewIfNeeded()
		XCTAssertEqual(
			loader.loadCommentsCallCount,
			1,
			"Expected a loading request once view is loaded"
		)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(
			loader.loadCommentsCallCount,
			2,
			"Expected a loading request once view is loaded"
		)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(
			loader.loadCommentsCallCount,
			3,
			"Expected yet another loading request once user initiates another reload"
		)
	}

	func test_loadingIndicator_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertTrue(
			sut.isShowingLoadingIndicator,
			"Expected loading indicator once view is loaded"
		)

		loader.completeLoading()
		XCTAssertFalse(
			sut.isShowingLoadingIndicator,
			"Expected no loading indicator once loading completes successfully"
		)

		sut.simulateUserInitiatedReload()
		XCTAssertTrue(
			sut.isShowingLoadingIndicator,
			"Expected loading indicator once user initiates a reload"
		)

		loader.completeLoadingWithError(at: 1)
		XCTAssertEqual(
			sut.isShowingLoadingIndicator,
			false,
			"Expected no loading indicator once user initiated loading completes with error"
		)
	}

	func test_loadCompletion_rendersSuccessfullyLoadedComments() {
		let (sut, loader) = makeSUT()

		let comment0 = makeComment(
			message: "a message",
			username: "a username"
		)

		let comment1 = makeComment(
			message: "another message",
			username: "another username"
		)

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [ImageComment]())

		let comments0 = [comment0]
		loader.completeLoading(with: comments0, at: 0)
		assertThat(sut, isRendering: comments0)

		sut.simulateUserInitiatedReload()
		let comments1 = [comment0, comment1]
		loader.completeLoading(with: comments1, at: 1)
		assertThat(sut, isRendering: comments1)
	}

	func test_loadCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
		let (sut, loader) = makeSUT()

		let comments = [makeComment()]

		sut.loadViewIfNeeded()
		loader.completeLoading(with: comments, at: 0)
		assertThat(sut, isRendering: comments)
		
		sut.simulateUserInitiatedReload()
		loader.completeLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}

	func test_loadCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let (sut, loader) = makeSUT()
		let comments = [makeComment()]

		sut.loadViewIfNeeded()
		loader.completeLoading(with: comments, at: 0)
		assertThat(sut, isRendering: comments)

		sut.simulateUserInitiatedReload()
		loader.completeLoadingWithError(at: 1)
		assertThat(sut, isRendering: comments)
	}

	func test_loadCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()

		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeLoading(at: 0)
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)
	}

	func test_loadCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, ImageCommentsPresenter.errorMessage)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_tapOnErrorView_hidesErrorMessage() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, ImageCommentsPresenter.errorMessage)

		sut.tableView.simulateTapOnErrorView()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	func test_deinit_cancelsRunningRequest() {
		var cancelCallCount = 0

		var sut: ImageCommentsViewController?

		autoreleasepool {
			sut = ImageCommentsUIComposer.imageCommentsComposedWith(
				commentsLoader: {
					PassthroughSubject<[ImageComment], Error>()
						.handleEvents(receiveCancel: {
							cancelCallCount += 1
						}).eraseToAnyPublisher()
				}
			)

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
	) -> (ImageCommentsViewController, LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(
			commentsLoader: loader.loadPublisher
		)
		trackForMemoryLeaks(loader, file: file, line: line) 
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}

	private func makeComment(
		message: String = "any message",
		username: String = "any username"
	) -> ImageComment {
		ImageComment(
			id: UUID(),
			message: message,
			createdAt: Date(),
			username: username
		)
	}

	private func assertThat(
		_ sut: ImageCommentsViewController,
		isRendering comments: [ImageComment],
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let numberOfRenderedComments = sut.numberOfRenderedComments()
		XCTAssertEqual(
			numberOfRenderedComments,
			comments.count,
			"comments count",
			file: file,
			line: line
		)

		let viewModel = ImageCommentsPresenter.map(comments)

		viewModel.comments.enumerated().forEach { index, comment in
			guard let cell = sut.commentCell(at: index) else {
				return XCTFail(
					"Expected ImageCommentCell instance at \(index) but got nil instead",
					file: file,
					line: line
				)
			}
			let message = cell.message
			XCTAssertEqual(
				message,
				comment.message,
				"message at \(index)",
				file: file,
				line: line
			)

			let username = cell.username
			XCTAssertEqual(
				username,
				comment.username,
				"username at \(index)",
				file: file,
				line: line
			)

			let date = cell.date
			XCTAssertEqual(
				date,
				comment.date,
				"date at \(index)",
				file: file,
				line: line
			)
		}
	}

	private class LoaderSpy {
		private var requests = [PassthroughSubject<[ImageComment], Error>]()

		var loadCommentsCallCount: Int { requests.count }

		func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
			let publisher = PassthroughSubject<[ImageComment], Error>()
			requests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}

		func completeLoading(
			with comments: [ImageComment] = [],
			at index: Int = 0
		) {
			requests[index].send(comments)
			requests[index].send(completion: .finished)
		}

		func completeLoadingWithError(
			at index: Int = 0
		) {
			requests[index].send(completion: .failure(anyNSError()))
		}
	}
}

extension ImageCommentsViewController {
	private var commentsSection: Int { 0 }

	var errorMessage: String? {
		errorView.message
	}

	var isShowingLoadingIndicator: Bool {
		refreshControl?.isRefreshing == true
	}

	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}

	func numberOfRenderedComments() -> Int {
		tableView.numberOfRows(
			inSection: commentsSection
		)
	}

	func commentCell(
		at row: Int
	) -> ImageCommentCell? {
		tableView.dataSource?.tableView(
			tableView,
			cellForRowAt: IndexPath(
				row: row,
				section: commentsSection
			)
		) as? ImageCommentCell
	}
}

extension ImageCommentCell {
	var message: String? {
		messageLabel?.text
	}

	var username: String? {
		usernameLabel?.text
	}

	var date: String? {
		dateLabel?.text
	}
}

//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Raphael Silva on 20/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Combine
@testable import EssentialApp
import EssentialFeed
import EssentialFeediOS
import XCTest

final class ImageCommentsUIComposer {
	static func imageCommentsComposed(
		with commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
	) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let imageCommentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		let presentationAdapter = ImageCommentsPresentationAdapter(loader: commentsLoader)
		imageCommentsController.delegate = presentationAdapter
		let presenter = ImageCommentsPresenter(
			commentsView: WeakRefVirtualProxy(imageCommentsController),
			loadingView: WeakRefVirtualProxy(imageCommentsController),
			errorView: WeakRefVirtualProxy(imageCommentsController)
		)
		presentationAdapter.presenter = presenter
		return imageCommentsController
	}
}

final class ImageCommentsPresentationAdapter:
	ImageCommentsViewControllerDelegate
{

	var presenter: ImageCommentsPresenter?

	let loader: () -> AnyPublisher<[ImageComment], Error>
	private var cancellables = Set<AnyCancellable>()

	init(loader: @escaping () -> AnyPublisher<[ImageComment], Error>) {
		self.loader = loader
	}

	func didRequestCommentsRefresh() {
		presenter?.didStartLoading()
		loader()
			.sink(
				receiveCompletion: { [presenter] result in
					switch result {
					case let .failure(error):
						presenter?.didFinishLoading(with: error)

					case .finished:
						break
					}
				},
				receiveValue: { [presenter] comments in
					presenter?.didFinishLoading(with: comments)
				}
			).store(in: &cancellables)
	}
}

final class ImageCommentsUIIntegrationTests: XCTestCase {

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
		loader.completeLoading(with: comments)
		assertThat(sut, isRendering: comments)
	}

	// MARK: - Helpers

	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (ImageCommentsViewController, LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposed(
			with: loader.loadPublisher
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
			"Expected \(comments.count) comments but got \(numberOfRenderedComments) instead.",
			file: file,
			line: line
		)

		let viewModel = ImageCommentsPresenter.map(comments)

		viewModel.comments.enumerated().forEach { index, comment in
			guard let cell = sut.commentCell(at: index) else {
				return XCTFail("Expected ImageCommentCell instance at \(index) but got nil instead", file: file, line: line)
			}
			let message = cell.message
			XCTAssertEqual(
				message,
				comment.message,
				"Expected message to be \(comment.message) but got \(String(describing: message)) instead",
				file: file,
				line: line
			)

			let username = cell.username
			XCTAssertEqual(
				username,
				comment.username,
				"Expected username to be \(comment.username) but got \(String(describing: username)) instead",
				file: file,
				line: line
			)

			let date = cell.date
			XCTAssertEqual(
				date,
				comment.date,
				"Expected date to be \(comment.date) but got \(String(describing: date)) instead",
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

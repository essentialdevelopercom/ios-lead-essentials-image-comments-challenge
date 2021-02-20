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

		let date = Date()
		let comments = [
			ImageComment(
				id: UUID(),
				message: "a message",
				createdAt: date,
				username: "a username"
			),
			ImageComment(
				id: UUID(),
				message: "another message",
				createdAt: date,
				username: "another username"
			)
		]

		sut.loadViewIfNeeded()
		loader.completeLoading(with: comments)

		let viewModels = ImageCommentsPresenter.map(comments, currentDate: date).comments

		let cell1 = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageCommentCell
		XCTAssertEqual(cell1?.usernameLabel?.text, viewModels[0].username)
		XCTAssertEqual(cell1?.dateLabel?.text, viewModels[0].date)
		XCTAssertEqual(cell1?.messageLabel?.text, viewModels[0].message)

		let cell2 = sut.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ImageCommentCell
		XCTAssertEqual(cell2?.usernameLabel?.text, viewModels[1].username)
		XCTAssertEqual(cell2?.dateLabel?.text, viewModels[1].date)
		XCTAssertEqual(cell2?.messageLabel?.text, viewModels[1].message)
	}

	func test_loadCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
		let (sut, loader) = makeSUT()

		let date = Date()
		let comments = [
			ImageComment(
				id: UUID(),
				message: "a message",
				createdAt: date,
				username: "a username"
			)
		]

		sut.loadViewIfNeeded()
		loader.completeLoading(with: comments)

		let viewModels = ImageCommentsPresenter.map(comments, currentDate: date).comments

		let cell1 = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageCommentCell
		XCTAssertEqual(cell1?.usernameLabel?.text, viewModels[0].username)
		XCTAssertEqual(cell1?.dateLabel?.text, viewModels[0].date)
		XCTAssertEqual(cell1?.messageLabel?.text, viewModels[0].message)

		sut.simulateUserInitiatedReload()
		loader.completeLoading(with: [], at: 1)
		XCTAssertEqual(
			sut.tableView.numberOfRows(inSection: 0),
			0,
			"Expected no comments after complete loading with empty image comments"
		)
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
	var isShowingLoadingIndicator: Bool {
		refreshControl?.isRefreshing == true
	}

	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
}

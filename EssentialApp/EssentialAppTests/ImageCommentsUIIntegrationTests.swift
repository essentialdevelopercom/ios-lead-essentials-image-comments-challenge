//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Rakesh Ramamurthy on 01/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import XCTest

class ImageCommentsUIComposer {
	static func imageCommentsComposeWith(commentsLoader: ImageCommentsLoader, url: URL, date: Date = Date()) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let commentsController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		let presentationAdapter = ImageCommentsPresentationAdapter(loader: commentsLoader, url: url)
		commentsController.delegate = presentationAdapter
		let presenter = ImageCommentsPresenter(
			imageCommentsView: commentsController,
			loadingView: commentsController,
			errorView: commentsController,
			currentDate: date
		)
		presentationAdapter.presenter = presenter
		return commentsController
	}
}

class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	var presenter: ImageCommentsPresenter?
	let loader: ImageCommentsLoader
	let url: URL

	init(loader: ImageCommentsLoader, url: URL) {
		self.loader = loader
		self.url = url
	}

	func didRequestCommentsRefresh() {
		presenter?.didStartLoadingComments()
		_ = loader.load(from: url) { result in
			switch result {
			case let .success(comments):
				self.presenter?.didFinishLoading(with: comments)
			case let .failure(error):
				self.presenter?.didFinishLoading(with: error)
			}
		}
	}
}

final class ImageCommentsUIIntegrationTests: XCTestCase {
	
	func test_loadCommentsAction_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

		sut.simulateUserInitiatedCommentsReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected a loading request once view is loaded")

		sut.simulateUserInitiatedCommentsReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}

	func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")

		loader.completeCommentsLoading()
		XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading completes successfully")

		sut.simulateUserInitiatedCommentsReload()
		XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user initiates a reload")

		loader.completeCommentsLoading(with: anyNSError())
		XCTAssertEqual(
			sut.isShowingLoadingIndicator,
			false,
			"Expected no loading indicator once user initiated loading completes with error"
		)
	}

	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let fixedDate = Date(timeIntervalSince1970: 1603497600) // 24 OCT 2020 - 00:00:00
		let (sut, loader) = makeSUT(date: fixedDate)

		let comment1 = ImageComment(
			id: UUID(),
			message: "a message",
			createdAt: Date(timeIntervalSince1970: 1603411200),
			author: "a username"
		) // 23 OCT 2020 - 00:00:00
		let comment2 = ImageComment(
			id: UUID(),
			message: "another message",
			createdAt: Date(timeIntervalSince1970: 1603494000),
			author: "another username"
		) // 23 OCT 2020 - 23:00:00
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment1, comment2])

		let cell1 = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageCommentCell
		XCTAssertEqual(cell1?.usernameLabel?.text, "a username")
		XCTAssertEqual(cell1?.createdAtLabel?.text, "1 day ago")
		XCTAssertEqual(cell1?.commentLabel?.text, "a message")

		let cell2 = sut.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ImageCommentCell
		XCTAssertEqual(cell2?.usernameLabel?.text, "another username")
		XCTAssertEqual(cell2?.createdAtLabel?.text, "1 hour ago")
		XCTAssertEqual(cell2?.commentLabel?.text, "another message")
	}

	// MARK: - Helpers
	private func makeSUT(
		url: URL = URL(string: "http://any-url.com")!,
		date: Date = Date(),
		file _: StaticString = #filePath,
		line _: UInt = #line
	) -> (ImageCommentsViewController, LoaderSpy) {
		let loader = LoaderSpy()
		let controller = ImageCommentsUIComposer.imageCommentsComposeWith(commentsLoader: loader, url: url, date: date)
		return (controller, loader)
	}

	private class LoaderSpy: ImageCommentsLoader {
		var loadCommentsCallCount = 0
		var completions = [(ImageCommentsLoader.Result) -> Void]()

		private struct Task: ImageCommentsLoaderTask {
			func cancel() {}
		}

		func load(from _: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
			loadCommentsCallCount += 1
			completions.append(completion)
			return Task()
		}
		
		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			completions[index](.success(comments))
		}

		func completeCommentsLoading(with error: Error, at index: Int = 0) {
			completions[index](.failure(error))
		}
	}
}

extension ImageCommentsViewController {
	func simulateUserInitiatedCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
}


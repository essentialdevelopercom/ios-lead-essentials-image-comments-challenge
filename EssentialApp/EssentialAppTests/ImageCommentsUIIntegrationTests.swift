//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 09/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
@testable import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsPresentationAdapter: ImageCommentsViewControllerDelegate {
	let imageLoader: ImageCommentsLoader
	var presenter: ImageCommentsPresenter?
	
	init(imageLoader: ImageCommentsLoader) {
		self.imageLoader = imageLoader
	}
	
	func didRequestImageCommentsRefresh() {
		presenter?.didStartLoadingComments()
		
		_ = imageLoader.loadImageComments(from: anyURL()) { [presenter] result in
			switch result {
			case let .success(comments):
				presenter?.didFinishLoadingComments(with: comments)
				
			case let .failure(error):
				presenter?.didFinishLoadingComments(with: error)
			}
		}
	}
}

final class ImageCommentsViewAdapter: ImageCommentsView {
	private weak var controller: ImageCommentsViewController?
	
	init(controller: ImageCommentsViewController) {
		self.controller = controller
	}
	
	func display(_ viewModel: ImageCommentsViewModel) {
		controller?.display(viewModel.comments.map { model in
			ImageCommentCellController(viewModel: { ImageCommentViewModel(authorUsername: model.author.username) })
		})
	}
}

final class ImageCommentsUIComposer {
	static func imageCommentsComposedWith(imageCommentsLoader: ImageCommentsLoader) -> ImageCommentsViewController {
		let presentationAdapter = ImageCommentsPresentationAdapter(imageLoader: imageCommentsLoader)
		
		let commentsController = makeImageCommentsViewController(
			delegate: presentationAdapter,
			title: ImageCommentsPresenter.title)
		
		presentationAdapter.presenter = ImageCommentsPresenter(
			commentsView: ImageCommentsViewAdapter(controller: commentsController),
			loadingView: WeakRefVirtualProxy(commentsController),
			errorView: WeakRefVirtualProxy(commentsController))
		
		return commentsController
	}
	
	private static func makeImageCommentsViewController(delegate: ImageCommentsViewControllerDelegate, title: String) -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let imageController = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		imageController.delegate = delegate
		imageController.title = title
		return imageController
	}
}

final class ImageCommentsUIIntegrationTests: XCTestCase {
	
	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadImageCommentsAction_requestImageCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 1, "Expected a loading request once view is loaded")
	}
	
	func test_loadingImageCommentsIndicator_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeImageCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to disable loading indicator while loading completes with success")
		
		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeImageCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected to disable loading indicator while loading completes with an error")
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let comment1 = makeImageComment()
		let comment2 = makeImageComment()
		let comment3 = makeImageComment()
		let comment4 = makeImageComment()
		let comment5 = makeImageComment()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
				
		loader.completeImageCommentsLoading(with: [comment1], at: 0)
		assertThat(sut, isRendering: [comment1])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoading(with: [comment1, comment2, comment3, comment4, comment5], at: 1)
		assertThat(sut, isRendering: [comment1, comment2, comment3, comment4, comment5])
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsListAfterNonEmptyResponse() {
		let comment1 = makeImageComment()
		let comment2 = makeImageComment()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment1, comment2], at: 0)
		assertThat(sut, isRendering: [comment1, comment2])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	func test_loadImageCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment1 = makeImageComment()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment1], at: 0)
		assertThat(sut, isRendering: [comment1])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment1])
	}
	
	func test_loadImageCommentsCompletion_redersErrorMessageConErrorUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeImageCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR"))
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	// MARK: - Helper
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(imageCommentsLoader: loader)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		return (sut, loader)
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, isRendering comments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		let numberOfRenderedComments = sut.numberOfRenderedImageCommentsViews()
		guard numberOfRenderedComments == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(numberOfRenderedComments) instead", file: file, line: line)
		}
		
		comments
			.enumerated()
			.forEach { index, comment in
				assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
			}
		
		executeRunLoopToCleanUpReferences()
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor comment: ImageComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.authorUsername, comment.author.username, "Expected author username to be \(String(describing: comment.author.username)) for comment view at index (\(index))", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
	
	private func makeImageComment() -> ImageComment {
		ImageComment(id: UUID(), message: "a message", createdAt: Date(), author: ImageComment.Author(username: "an username"))
	}
	
	private class LoaderSpy: ImageCommentsLoader, ImageCommentsViewControllerDelegate {
		private struct Task: ImageCommmentsLoaderTask {
			func cancel() { }
		}
		
		private(set) var completions = [(url: URL, handler: (ImageCommentsLoader.Result) -> Void)]()
		
		var loadImageCommentsCallCount: Int {
			completions.count
		}
		
		func didRequestImageCommentsRefresh() {
			_ = loadImageComments(from: anyURL()) { _ in }
		}
		
		func loadImageComments(from url: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommmentsLoaderTask {
			completions.append((url, completion))
			return Task()
		}
		
		func completeImageCommentsLoading(at index: Int) {
			completions[index].handler(.success([]))
		}
		
		func completeImageCommentsLoadingWithError(at index: Int) {
			completions[index].handler(.failure(anyNSError()))
		}
		
		func completeImageCommentsLoading(with comments: [ImageComment], at index: Int) {
			completions[index].handler(.success(comments))
		}
	}
	
}

private extension ImageCommentsUIIntegrationTests {
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}

private extension ImageCommentsViewController {
	var isShowingLoadingIndicator: Bool {
		refreshControl?.isRefreshing ?? false
	}
	
	var errorMessage: String? {
		errorView?.message
	}
	
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	func numberOfRenderedImageCommentsViews() -> Int {
		tableView.numberOfRows(inSection: commentsSectionIndex)
	}
	
	private var commentsSectionIndex: Int { 0 }
	
	func imageCommentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedImageCommentsViews() > row else {
			return nil
		}
		
		let dataSource = tableView.dataSource
		let index = IndexPath(row: row, section: commentsSectionIndex)
		return dataSource?.tableView(tableView, cellForRowAt: index)
	}
}

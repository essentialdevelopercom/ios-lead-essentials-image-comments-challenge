//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Bogdan Poplauschi on 02/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import EssentialApp
import XCTest

final class ImageCommentsUIIntegrationTests: XCTestCase {
	
	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadCommentsActions_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 2, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}
	
	func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	}
	
	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let imageComments = uniqueComments()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: imageComments.comments)
		assertThat(sut, isRendering: imageComments.presentableComments)
	}
	
	func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
		let imageComments = uniqueComments()
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: imageComments.comments, at: 0)
		assertThat(sut, isRendering: imageComments.presentableComments)

		sut.simulateUserInitiatedImageCommentsReload()
		loader.completeCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let imageComments = uniqueComments()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: imageComments.comments)
		assertThat(sut, isRendering: imageComments.presentableComments)
		
		sut.simulateUserInitiatedImageCommentsReload()
		loader.completeCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: imageComments.presentableComments)
	}
	
	func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR"))
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_cancelsCommentsLoading_whenViewIsNotVisible() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.cancelledRequests, [], "Expected no cancelled requests until comments are not visibile")
		
		loader.completeCommentsLoading()
		XCTAssertEqual(loader.cancelledRequests, [], "Expected no cancelled requests after loading")
		
		sut.simulateUserInitiatedImageCommentsReload()
		sut.viewWillDisappear(false)
		XCTAssertEqual(loader.cancelledRequests.count, 1, "Expected one cancelled request")
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
		
	// MARK: - Helpers
	
	private func assertThat(
		_ sut: ImageCommentsViewController,
		isRendering imageComments: [PresentableImageComment],
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		guard sut.numberOfRenderedImageComments() == imageComments.count else {
			return XCTFail("Expected \(imageComments.count) images, got \(sut.numberOfRenderedImageComments()) instead.", file: file, line: line)
		}
		
		for (index, imageComment) in imageComments.enumerated() {
			assertThat(sut, hasViewConfiguredFor: imageComment, at: index)
		}
	}
	
	private func assertThat(
		_ sut: ImageCommentsViewController,
		hasViewConfiguredFor imageComment: PresentableImageComment,
		at index: Int,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.usernameText, imageComment.author, "Expected username text to be \(String(describing: imageComment.author)) for image comment view at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.createdAtText, imageComment.createdAt, "Expected created at text to be \(String(describing: imageComment.createdAt)) for image comment view at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.commentText, imageComment.message, "Expected comment text to be \(String(describing: imageComment.author)) for image comment view at index \(index)", file: file, line: line)
	}
	
	private func makeSUT(date: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(commentsLoader: loader, date: date)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func uniqueComments(currentDate: Date = Date()) -> (comments: [ImageComment], presentableComments: [PresentableImageComment]) {
		let comments = [
			ImageComment(
				id: UUID(),
				message: "a message",
				createdAt: Date(timeIntervalSinceReferenceDate: currentDate.timeIntervalSinceReferenceDate - 60 * 60 * 24),
				author: ImageCommentAuthor(username: "a username")
			),
			ImageComment(
				id: UUID(),
				message: "another message",
				createdAt: Date(timeIntervalSinceReferenceDate: currentDate.timeIntervalSinceReferenceDate - 60 * 60),
				author: ImageCommentAuthor(username: "another username")
			),
		]
		
		let presentableComments = [
			PresentableImageComment(createdAt: "1 day ago", message: comments[0].message, author: comments[0].author.username),
			PresentableImageComment(createdAt: "1 hour ago", message: comments[1].message, author: comments[1].author.username)
		]
		
		return (comments, presentableComments)
	}
	
	private func anyDate() -> Date {
		return Date(timeIntervalSinceReferenceDate: 638556190)
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
	
	private class LoaderSpy: ImageCommentsLoader {
		
		private struct TaskSpy: ImageCommentsLoaderTask {
			let id: UUID
			let cancelCallback: () -> Void
			
			func cancel() {
				cancelCallback()
			}
		}
		
		private var imageCommentsRequests = [(ImageCommentsLoader.Result) -> Void]()
		
		private(set) var cancelledRequests = [UUID]()
		
		var loadImageCommentsCallCount: Int {
			return imageCommentsRequests.count
		}
		
		func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
			imageCommentsRequests[index](.success(comments))
		}
		
		func completeCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			imageCommentsRequests[index](.failure(error))
		}
		
		@discardableResult
		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
			imageCommentsRequests.append(completion)
			let taskId = UUID()
			return TaskSpy(id: taskId) { [weak self] in
				self?.cancelledRequests.append(taskId)
			}
		}
	}
}

extension ImageCommentsViewController {
	func simulateUserInitiatedImageCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	func numberOfRenderedImageComments() -> Int {
		tableView.numberOfRows(inSection: imageCommentsSection)
	}
	
	func imageCommentView(at row: Int) -> UITableViewCell? {
		let indexPath = IndexPath(row: row, section: imageCommentsSection)
		let ds = tableView.dataSource
		return ds?.tableView(tableView, cellForRowAt: indexPath)
	}
	
	var errorMessage: String? {
		errorView?.message
	}
	
	var imageCommentsSection: Int { 0 }
}

extension ImageCommentCell {
	var commentText: String? { commentLabel?.text }
	var usernameText: String? { usernameLabel?.text }
	var createdAtText: String? { createdAtLabel?.text }
}

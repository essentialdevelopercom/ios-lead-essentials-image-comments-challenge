//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Eric Garlock on 3/10/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialApp
import EssentialFeed
import EssentialFeediOS

class ImageCommentsUIIntegrationTests: XCTestCase {

	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()
		
		XCTAssertEqual(sut.title, localized("COMMENT_VIEW_TITLE"))
	}
	
	func test_loadImageCommentActions_requestImageCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadCallCount, 0)
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1)
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCallCount, 2)
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCallCount, 3)
	}
	
	func test_loadImageCommentIndicator_isVisibleWhileLoading() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeImageCommentLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
		
		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeImageCommentLoadingWithError(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
	}
	
	func test_loadImageCommentCompletion_rendersSuccessfullyLoadedImageComments() {
		let (sut, loader) = makeSUT()
		
		let fixedDate = Date()
		let comment0 = makeImageComment(id: UUID(), message: "message0", createdAt: fixedDate.adding(seconds: -30), username: "username0")
		let comment1 = makeImageComment(id: UUID(), message: "message1", createdAt: fixedDate.adding(seconds: -30 * 60), username: "username1")
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeImageCommentLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentLoading(with: [comment0, comment1], at: 1)
		assertThat(sut, isRendering: [comment0, comment1])
	}
	
	func test_loadImageCommentCompletion_rendersSuccessfullyLoadedEmptyImageCommentsAfterNonEmptyImageComments() {
		let (sut, loader) = makeSUT()
		
		let fixedDate = Date()
		let comment0 = makeImageComment(id: UUID(), message: "message0", createdAt: fixedDate.adding(seconds: -30), username: "username0")
		let comment1 = makeImageComment(id: UUID(), message: "message1", createdAt: fixedDate.adding(seconds: -30 * 60), username: "username1")
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeImageCommentLoading(with: [comment0, comment1], at: 0)
		assertThat(sut, isRendering: [comment0, comment1])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	func test_loadImageCommentCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let (sut, loader) = makeSUT()
		
		let fixedDate = Date()
		let comment0 = makeImageComment(id: UUID(), message: "message0", createdAt: fixedDate.adding(seconds: -30), username: "username0")
		let comment1 = makeImageComment(id: UUID(), message: "message1", createdAt: fixedDate.adding(seconds: -30 * 60), username: "username1")
		
		sut.loadViewIfNeeded()
		loader.completeImageCommentLoading(with: [comment0, comment1], at: 0)
		assertThat(sut, isRendering: [comment0, comment1])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment0, comment1])
	}
	
	func test_loadImageCommentCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeImageCommentLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("COMMENT_VIEW_ERROR_MESSAGE"))
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentLoading(at: 1)
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_tapOnErrorView_hidesErrorMessage() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeImageCommentLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("COMMENT_VIEW_ERROR_MESSAGE"))
		
		sut.simulateTapOnErrorViewButton()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_deinit_cancelsRunningRequest() {
		var cancelCallCount = 0
		
		var sut: ImageCommentsViewController?
		
		autoreleasepool {
			sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: LoaderSpy() {
				cancelCallCount += 1
			})
			
			sut?.loadViewIfNeeded()
		}
		
		XCTAssertEqual(cancelCallCount, 0)
		
		sut = nil
		
		XCTAssertEqual(cancelCallCount, 1)
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeImageComment(id: UUID, message: String, createdAt: Date, username: String) -> ImageComment {
		return ImageComment(
			id: id,
			message: message,
			createdAt: createdAt,
			author: ImageCommentAuthor(username: username))
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, isRendering imageComments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		guard sut.numberOfRenderedImageCommentViews() == imageComments.count else {
			return XCTFail("Expected \(imageComments.count) image comments, got \(sut.numberOfRenderedImageCommentViews()) instead.", file: file, line: line)
		}
		
		let viewModels = ImageCommentPresenter.map(imageComments)
		
		viewModels.enumerated().forEach { index, viewModel in
			assertThat(sut, hasViewConfiguredFor: viewModel, at: index, file: file, line: line)
		}
		
		executeRunLoopToCleanUpReferences()
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor imageComment: ImageCommentViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.messageText, imageComment.message, "for view at index (\(index))", file: file, line: line)
		XCTAssertEqual(cell.createdText, imageComment.created, "for view at index (\(index))", file: file, line: line)
		XCTAssertEqual(cell.usernameText, imageComment.username, "for view at index (\(index))", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
	
	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class LoaderSpy: ImageCommentLoader {
		
		private(set) var completions = [(ImageCommentLoader.Result) -> Void]()
		private let onCancel: () -> Void
		
		init(_ onCancel: @escaping () -> Void = { }) {
			self.onCancel = onCancel
		}
		
		var loadCallCount: Int {
			return completions.count
		}
		
		private struct TaskSpy: ImageCommentLoaderDataTask {
			
			private let onCancel: () -> Void
			
			init(_ onCancel: @escaping () -> Void = { }) {
				self.onCancel = onCancel
			}
			
			func cancel() {
				onCancel()
			}
		}
		
		func load(completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderDataTask {
			completions.append(completion)
			return TaskSpy(onCancel)
		}
		
		func completeImageCommentLoading(with imageComments: [ImageComment] = [], at index: Int = 0) {
			completions[index](.success(imageComments))
		}
		
		func completeImageCommentLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "error", code: 0)
			completions[index](.failure(error))
		}
	}
	
	

}

extension ImageCommentsViewController {
	
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	func simulateTapOnErrorViewButton() {
		errorView.button.simulateTap()
	}
	
	func numberOfRenderedImageCommentViews() -> Int {
		return tableView.numberOfRows(inSection: imageCommentsSection)
	}
	
	func imageCommentView(at row: Int) -> ImageCommentCell? {
		guard numberOfRenderedImageCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: imageCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
	}
	
	func imageCommentMessage(at row: Int) -> String? {
		return imageCommentView(at: row)?.labelMessage.text
	}
	
	var imageCommentsSection: Int {
		return 0
	}
	
	var errorMessage: String? {
		return errorView.message
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
}

extension ImageCommentCell {
	var messageText: String? { return labelMessage.text }
	var createdText: String? { return labelCreated.text }
	var usernameText: String? { return labelUsername.text }
}

extension Date {
	
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
	
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}

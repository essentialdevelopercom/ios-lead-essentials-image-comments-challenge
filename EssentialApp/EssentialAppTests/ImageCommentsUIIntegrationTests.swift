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
		let comment0 = makeImageComment(id: UUID(), message: "message0", createdAt: (fixedDate.adding(seconds: -30), "30 seconds ago"), username: "username0")
		let comment1 = makeImageComment(id: UUID(), message: "message1", createdAt: (fixedDate.adding(seconds: -30 * 60), "30 minutes ago"), username: "username1")
		let comment2 = makeImageComment(id: UUID(), message: "message2", createdAt: (fixedDate.adding(days: -1), "1 day ago"), username: "username2")
		let comment3 = makeImageComment(id: UUID(), message: "message3", createdAt: (fixedDate.adding(days: -2), "2 days ago"), username: "username3")
		let comment4 = makeImageComment(id: UUID(), message: "message4", createdAt: (fixedDate.adding(days: -7), "1 week ago"), username: "username4")
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeImageCommentLoading(with: [comment0.model], at: 0)
		assertThat(sut, isRendering: [comment0.viewModel])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentLoading(with: [comment0.model, comment1.model, comment2.model, comment3.model, comment4.model], at: 1)
		assertThat(sut, isRendering: [comment0.viewModel, comment1.viewModel, comment2.viewModel, comment3.viewModel, comment4.viewModel])
	}
	
	func test_loadImageCommentCompletion_rendersSuccessfullyLoadedEmptyImageCommentsAfterNonEmptyImageComments() {
		let (sut, loader) = makeSUT()
		
		let fixedDate = Date()
		let comment0 = makeImageComment(id: UUID(), message: "message0", createdAt: (fixedDate.adding(seconds: -30), "30 seconds ago"), username: "username0")
		let comment1 = makeImageComment(id: UUID(), message: "message1", createdAt: (fixedDate.adding(seconds: -30 * 60), "30 minutes ago"), username: "username1")
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeImageCommentLoading(with: [comment0.model, comment1.model], at: 0)
		assertThat(sut, isRendering: [comment0.viewModel, comment1.viewModel])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	func test_loadImageCommentCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let (sut, loader) = makeSUT()
		
		let fixedDate = Date()
		let comment0 = makeImageComment(id: UUID(), message: "message0", createdAt: (fixedDate.adding(seconds: -30), "30 seconds ago"), username: "username0")
		let comment1 = makeImageComment(id: UUID(), message: "message1", createdAt: (fixedDate.adding(seconds: -30 * 60), "30 minutes ago"), username: "username1")
		
		sut.loadViewIfNeeded()
		loader.completeImageCommentLoading(with: [comment0.model, comment1.model], at: 0)
		assertThat(sut, isRendering: [comment0.viewModel, comment1.viewModel])
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment0.viewModel, comment1.viewModel])
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
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeImageComment(id: UUID, message: String, createdAt: (date: Date, formatted: String), username: String) -> (model: ImageComment, viewModel: ImageCommentViewModel) {
		let model = ImageComment(
			id: id,
			message: message,
			createdAt: createdAt.date,
			author: ImageCommentAuthor(username: username))
		let viewModel = ImageCommentViewModel(message: message, created: createdAt.formatted, username: username)
		return (model, viewModel)
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, isRendering imageComments: [ImageCommentViewModel], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		guard sut.numberOfRenderedImageCommentViews() == imageComments.count else {
			return XCTFail("Expected \(imageComments.count) image comments, got \(sut.numberOfRenderedImageCommentViews()) instead.", file: file, line: line)
		}
		
		imageComments.enumerated().forEach { index, imageComment in
			assertThat(sut, hasViewConfiguredFor: imageComment, at: index, file: file, line: line)
		}
		
		executeRunLoopToCleanUpReferences()
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor imageComment: ImageCommentViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
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
		
		var loadCallCount: Int {
			return completions.count
		}
		
		private struct TaskSpy: ImageCommentLoaderDataTask {
			func cancel() {
				
			}
		}
		
		func load(completion: @escaping (ImageCommentLoader.Result) -> Void) -> ImageCommentLoaderDataTask {
			completions.append(completion)
			return TaskSpy()
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
	
	func imageCommentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedImageCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: imageCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index)
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

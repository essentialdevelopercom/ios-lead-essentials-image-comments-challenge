//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Alok Subedi on 04/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialApp

class ImageCommentsUIIntegrationTests: XCTestCase {

	func test_init_doesNotRequestLoadImageComments() {
		let (_, loader) = makeSUT()
		
		XCTAssertEqual(loader.loadCallCount, 0)
	}
	
	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadImmageCommentsAction_requestsToLoadImageComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1)
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCallCount, 2)
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCallCount, 3)
	}
	
	func test_loadingIndicator_isVisibleWhileLoadingImageComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator)
		
		loader.completeLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator)
		
		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator)
		
		loader.completeLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator)
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedImageComments() {
		let date = Date()
		let imageComment0 = makeComment(message: "message", date: (date: date.adding(days: -1), string: "1 day ago"), author: "user")
		let imageComment1 = makeComment(message: "another message", date: (date: date.adding(days: -2), string: "2 days ago"), author: "another user")
		let imageComment2 = makeComment(message: "third message", date: (date: date.adding(days: -31), string: "1 month ago"), author: "third user")
		let imageComment3 = makeComment(message: "forth message", date: (date: date.adding(days: -366), string: "1 year ago"), author: "forth user")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeLoading(with: [imageComment0.model], at: 0)
		assertThat(sut, isRendering: [imageComment0.expectedContent])
		
		sut.simulateUserInitiatedReload()
		loader.completeLoading(with: [imageComment0.model, imageComment1.model, imageComment2.model, imageComment3.model], at: 1)
		assertThat(sut, isRendering: [imageComment0.expectedContent, imageComment1.expectedContent, imageComment2.expectedContent, imageComment3.expectedContent])
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedEmptyImageCommentsAfterNonEmptyImageComments() {
		let date = Date()
		let imageComment0 = makeComment(message: "message", date: (date: date.adding(days: -1), string: "1 day ago"), author: "user")
		let imageComment1 = makeComment(message: "another message", date: (date: date.adding(days: -2), string: "2 days ago"), author: "another user")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeLoading(with: [imageComment0.model, imageComment1.model], at: 0)
		assertThat(sut, isRendering: [imageComment0.expectedContent, imageComment1.expectedContent])
		
		sut.simulateUserInitiatedReload()
		loader.completeLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	func test_loadImageCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let date = Date()
		let imageComment0 = makeComment(message: "message", date: (date: date.adding(days: -1), string: "1 day ago"), author: "user")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeLoading(with: [imageComment0.model], at: 0)
		assertThat(sut, isRendering: [imageComment0.expectedContent])
		
		sut.simulateUserInitiatedReload()
		loader.completeLoadingWithError(at: 1)
		assertThat(sut, isRendering: [imageComment0.expectedContent])
	}
	
	func test_loadImageCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)
		
		loader.completeLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR"))
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_tapOnErrorView_hidesErrorMessage() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR"))

		sut.simulateErrorViewTap()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_onDeinit_cancelRequestFeedFromLoader() {
		let loader = LoaderSpy()
		var sut: ImageCommentsViewController?
		
		autoreleasepool {
			sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader.loadPublisher)
			sut?.loadViewIfNeeded()
		}

		XCTAssertEqual(loader.cancelCount, 0)

		sut = nil
		XCTAssertEqual(loader.cancelCount, 1)
	}
	
	func test_loadImageCommentsCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeLoading(at: 0)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	//MARK: Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader.loadPublisher)
		
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		
		return (sut, loader)
	}
	
	struct ExpectedCellContent {
		let username: String
		let message: String
		let date: String
	}

	private func makeComment(message: String, date: (date: Date, string: String), author: String) -> (model: ImageComment, expectedContent: ExpectedCellContent) {
		return (
			ImageComment(id: UUID(), message: message, createdDate: date.date, author: CommentAuthor(username: author)),
			ExpectedCellContent(username: author, message: message, date: date.string)
		)
	}
	
	private func assertThat(_ sut: ImageCommentsViewController, isRendering imageComments: [ExpectedCellContent], file: StaticString = #file, line: UInt = #line) {
		XCTAssertEqual(sut.numberOfRenderedImageCommentsViews, imageComments.count, file: file, line: line)
		
		imageComments.enumerated().forEach { index, comment in
			let cell = sut.renderedCell(at: index)
			XCTAssertEqual(cell?.usernameText, comment.username, file: file, line: line)
			XCTAssertEqual(cell?.createdTimetext, comment.date, file: file, line: line)
			XCTAssertEqual(cell?.messageText, comment.message, file: file, line: line)
		}
	}
	
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
	
	private class LoaderSpy: ImageCommentsLoader {
		private(set) var cancelCount = 0
		
		private var imageCommentsRequests = [(ImageCommentsLoader.Result) -> Void]()
		var loadCallCount: Int {
			return imageCommentsRequests.count
		}
		
		private class Task: ImageCommentsLoaderTask {
			let onCancel: () -> Void

			init(onCancel: @escaping () -> Void) {
				self.onCancel = onCancel
			}

			func cancel() {
				onCancel()
			}
		}
		
		func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
			imageCommentsRequests.append((completion))
			return Task { [weak self] in
				self?.cancelCount += 1
			}
		}
		
		func completeLoading(with comments: [ImageComment] = [], at index: Int) {
			imageCommentsRequests[index](.success(comments))
		}
		
		func completeLoadingWithError(at index: Int) {
			imageCommentsRequests[index](.failure(NSError()))
		}
	}
}

extension Date {
	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}

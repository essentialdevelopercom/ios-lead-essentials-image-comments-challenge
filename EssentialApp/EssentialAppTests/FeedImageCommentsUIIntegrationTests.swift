//
//  FeedImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Danil Vassyakin on 4/19/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedImageCommentsUIIntegrationTests: XCTestCase {

	func test_imageCommentsView_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, localized("FEED_COMMENT_TITLE"))
	}
	
	func test_loadImageCommentsAction_requestsCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.commentsCallCount, 0)

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.commentsCallCount, 1, "Expected to load when view did load")
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.commentsCallCount, 2, "Expected to show the loading indicator when the user initiates a reload")
		
		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.commentsCallCount, 3, "Expected to show the loading indicator when the user initiates a reload")
	}

	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let comment0 = makeComment(message: "message0", author: "author0")
		let comment1 = makeComment(message: "message1", author: "author1")
		let comment2 = makeComment(message: "message2", author: "author2")
		let comment3 = makeComment(message: "message3", author: "author3")

		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		sut.simulateTapOnErrorView()
		loader.completeCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [comment0, comment1, comment2, comment3], at: 1)
		assertThat(sut, isRendering: [comment0, comment1, comment2, comment3])
	}
	
	func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
		let comment0 = makeComment(message: "message0", author: "author0")
		let comment1 = makeComment(message: "message1", author: "author1")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment0, comment1], at: 0)
		assertThat(sut, isRendering: [comment0, comment1])
		
		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	func test_loadCommentsCompletion_rendersErrorMessageOnLoaderFailureUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("FEED_COMMENTS_VIEW_ERROR_MESSAGE"))

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}
	
	func test_loadCommentsCompletion_rendersErrorMessageOnLoaderFailureUntilTap() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, localized("FEED_COMMENTS_VIEW_ERROR_MESSAGE"))

		sut.simulateTapOnErrorView()

		let exp = expectation(description: "Waiting for the next run loop iteration for the tap processing")
		DispatchQueue.main.async { [weak sut] in
			XCTAssertEqual(sut?.errorMessage, nil)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 0.1)
	}
	
	func test_cancelCommentsLoading_whenViewIsDismissed() {
		let loader = LoaderSpy()
		var vc: FeedCommentsViewController?
		
		autoreleasepool {
			vc = ImageCommentsUIComposer.feedCommentsComposedWith(commentLoader: loader.loadPublisher) as? FeedCommentsViewController
			vc?.loadViewIfNeeded()
		}
		
		XCTAssertEqual(loader.cancelledRequests, 0, "Expected no cancelled requests until task is cancelled")
		vc = nil
		XCTAssertEqual(loader.cancelledRequests, 1, "Expected cancelled requests after view is deinited/disappeared")
	}
	
	func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		let comment = makeComment(message: "message0", author: "author0")
		
		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeCommentsLoading(with: [comment], at: 0)
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.feedCommentsComposedWith(commentLoader: loader.loadPublisher) as! FeedCommentsViewController
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeComment(message: String = "message", author: String = "author") -> FeedComment {
		FeedComment(id: UUID(), message: message, createdAt: Date(), author: .init(username: author))
	}
	
}

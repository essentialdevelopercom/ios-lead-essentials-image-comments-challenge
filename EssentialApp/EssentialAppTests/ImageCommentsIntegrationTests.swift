//
//  ImageCommentsIntegrationTests.swift
//  ImageCommentsIntegrationTests
//
//  Created by Ángel Vázquez on 20/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import EssentialApp
import XCTest
import UIKit

class ImageCommentsIntegrationTests: XCTestCase {
	func test_commentsScreen_hasLocalizedTitle() {
		let (sut, _) = makeSUT(url: anyURL())
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadCommentsActions_requestsLoadingCommentsFromURL() {
		let url = URL(string: "https://any-url.com")!
		let (sut, loader) = makeSUT(url: url)
		XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests upon creation")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCallCount, 1, "Expected a single loading request when view has loaded")
		
		sut.simulateUserInitiatedReloading()
		XCTAssertEqual(loader.loadCallCount, 2, "Expected a second loading request once user initiates a reload")
		
		sut.simulateUserInitiatedReloading()
		XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another reload")
	}
	
	func test_loadingSpinner_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT(url: anyURL())
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingSpinner, "Expected loading spinner to be shown when view has loaded")
		
		loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingSpinner, "Expected loading spinner to stop animating upon loader successfult completion")
		
		sut.simulateUserInitiatedReloading()
		XCTAssertTrue(sut.isShowingLoadingSpinner, "Expected loading spinner to start animating once user requests a reload")
		
		loader.completeCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingSpinner, "Expected loading spinner to stop animating upon loader completion with error")
	}
	
	func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let staticDate = makeDateFromTimestamp(1_605_868_247, description: "2020-11-20 10:30:47 +0000")
		let currentDate = { staticDate }
		let comment0 = makeComment(
			message: "a message",
			creationDate: makeDateFromTimestamp(1_605_860_313, description: "2020-11-20 08:18:33 +0000"),
			author: "an author"
		)
		let comment1 = makeComment(
			message: "another message",
			creationDate: makeDateFromTimestamp(1_605_713_544, description: "2020-11-18 15:32:24 +0000"),
			author: "a second author"
		)
		let comment2 = makeComment(
			message: "another message",
			creationDate: makeDateFromTimestamp(1_604_571_429, description: "2020-11-05 10:17:09 +0000"),
			author: "a third author"
		)
		let comment3 = makeComment(
			message: "a fourth message",
			creationDate: makeDateFromTimestamp(1_602_510_149, description: "2020-10-12 13:42:29 +0000"),
			author: "another author"
		)
		let comment4 = makeComment(
			message: "a fifth message",
			creationDate: makeDateFromTimestamp(1_488_240_000, description: "2017-02-28 00:00:00 +0000"),
			author: "a fifth author"
		)
		let comments = [comment0, comment1, comment2, comment3, comment4]
		let (sut, loader) = makeSUT(url: anyURL(), currentDate: currentDate)
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: makePresentableViewModels(from: [comment0], currentDate: currentDate))
		
		sut.simulateUserInitiatedReloading()
		loader.completeCommentsLoading(with: comments, at: 1)
		assertThat(sut, isRendering: makePresentableViewModels(from: comments, currentDate: currentDate))
	}
	
	func test_loadCommentsCompletion_showsLocalizedErrorMessageOnLoaderError() {
		let (sut, loader) = makeSUT(url: anyURL())
		
		sut.loadViewIfNeeded()
		XCTAssertNil(sut.errorMessage, "Expected no error message to be shown when view is loaded")
		
		loader.completeCommentsLoadingWithError()
		XCTAssertEqual(sut.errorMessage, localized("IMAGE_COMMENTS_VIEW_ERROR_MESSAGE"), "Expected error message to be shown after loader completes with error")
		
		sut.simulateUserInitiatedReloading()
		XCTAssertNil(sut.errorMessage, "Expected no error message to be shown when user reloads comments")
	}
	
	func test_errorView_dismissesLocalizedErrorMessageOnTap() {
		let (sut, loader) = makeSUT(url: anyURL())
		
		sut.loadViewIfNeeded()
		XCTAssertNil(sut.errorMessage, "Expected no error message to be shown when view is loaded")
		
		loader.completeCommentsLoadingWithError()
		XCTAssertEqual(sut.errorMessage, localized("IMAGE_COMMENTS_VIEW_ERROR_MESSAGE"), "Expected error message to be shown after loader completes with error")
		
		sut.simulateTapOnErrorMessage()
		XCTAssertNil(sut.errorMessage, "Expected no error message to be shown after tapping on error message")
	}
	
	func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let staticDate = makeDateFromTimestamp(1_605_868_247, description: "2020-11-20 10:30:47 +0000")
		let currentDate = { staticDate }
		let comment = makeComment(
			message: "a message",
			creationDate: makeDateFromTimestamp(1_605_860_313, description: "2020-11-20 08:18:33 +0000"),
			author: "an author"
		)
		let (sut, loader) = makeSUT(url: anyURL(), currentDate: currentDate)
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment], at: 0)
		assertThat(sut, isRendering: makePresentableViewModels(from: [comment], currentDate: currentDate))
		
		sut.simulateUserInitiatedReloading()
		loader.completeCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: makePresentableViewModels(from: [comment], currentDate: currentDate))
	}
	
	func test_loadComments_cancelsAnyRunningRequestsWhenNavigatingBack() {
		let loader = LoaderSpy()
		let url = URL(string: "https://any-url.com")!
		var sut: ImageCommentsViewController?
		
		autoreleasepool {
			sut = ImageCommentsUIComposer.imageCommentsComposedWith(url: url, currentDate: Date.init, loader: loader)
			XCTAssertEqual(loader.cancelCallCount, 0, "Expected no cancelled requests upon creation")
			
			sut?.loadViewIfNeeded()
			XCTAssertEqual(loader.cancelCallCount, 0, "Expected no cancelled requests after view is loaded")
			
			loader.completeCommentsLoading(at: 0)
			XCTAssertEqual(loader.cancelCallCount, 0, "Expected no cancelled requests after task is already finished successfully")
			
			sut?.simulateUserInitiatedReloading()
			loader.completeCommentsLoadingWithError(at: 1)
			XCTAssertEqual(loader.cancelCallCount, 0, "Expected no cancelled requests after task is already finished with an error")
			
			sut?.simulateUserInitiatedReloading()
		}
		
		sut = nil
		XCTAssertEqual(loader.cancelCallCount, 1, "Expected cancelling request after user navigates back from comments screen")
	}
	
	func test_loadComments_doesNotCancelAlreadyFinishedRequests() {
		let loader = LoaderSpy()
		let url = URL(string: "https://any-url.com")!
		var sut: ImageCommentsViewController?
		
		autoreleasepool {
			sut = ImageCommentsUIComposer.imageCommentsComposedWith(url: url, currentDate: Date.init, loader: loader)
			XCTAssertEqual(loader.cancelCallCount, 0, "Expected no cancelled requests upon creation")
			
			sut?.loadViewIfNeeded()
			XCTAssertEqual(loader.cancelCallCount, 0, "Expected no cancelled requests after view is loaded")
			
			loader.completeCommentsLoading(at: 0)
			XCTAssertEqual(loader.cancelCallCount, 0, "Expected no cancelled requests after task is already finished successfully")
			
			sut?.simulateUserInitiatedReloading()
			loader.completeCommentsLoadingWithError(at: 1)
			XCTAssertEqual(loader.cancelCallCount, 0, "Expected no cancelled requests after task is already finished with an error")
		}
		
		sut = nil
		XCTAssertEqual(loader.cancelCallCount, 0, "Expected no cancelled requests as all requests were finished before deallocating screen")
	}
	
	func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT(url: anyURL())
		
		sut.loadViewIfNeeded()
		
		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeCommentsLoading(with: [], at: 0)
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL, currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(url: url, currentDate: currentDate, loader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeDateFromTimestamp(_ timestamp: TimeInterval, description: String, file: StaticString = #file, line: UInt = #line) -> Date {
		Date(timeIntervalSince1970: timestamp)
	}
	
	private func makeComment(message: String, creationDate: Date, author: String) -> ImageComment {
		ImageComment(id: UUID(), message: message, creationDate: creationDate, author: author)
	}
	
	private func makePresentableViewModels(from imageComments: [ImageComment], currentDate: @escaping () -> Date) -> [ImageCommentViewModel] {
		ImageCommentViewModelMapper.map(imageComments, currentDate: currentDate, locale: Locale(identifier: "en_US_POSIX"))
	}
}

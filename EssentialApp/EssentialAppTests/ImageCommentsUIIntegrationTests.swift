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
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedComments_inExactOrderAsReturnedFromAPI() {
		let comment1 = makeImageComment()
		let comment2 = makeImageComment()
		let comment3 = makeImageComment()
		let comment4 = makeImageComment()
		let comment5 = makeImageComment()
		let configuration = Self.makeTimeFormatConfiguration(date: Date())
		let (sut, loader) = makeSUT(timeFormatConfiguration: configuration)
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [], timeFormatConfiguration: configuration)
				
		loader.completeImageCommentsLoading(with: [comment1], at: 0)
		assertThat(sut, isRendering: [comment1], timeFormatConfiguration: configuration)
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoading(with: [comment1, comment2, comment3, comment4, comment5], at: 1)
		assertThat(sut, isRendering: [comment1, comment2, comment3, comment4, comment5], timeFormatConfiguration: configuration)
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsListAfterNonEmptyResponse() {
		let comment1 = makeImageComment()
		let comment2 = makeImageComment()
		let configuration = Self.makeTimeFormatConfiguration(date: Date())
		let (sut, loader) = makeSUT(timeFormatConfiguration: configuration)

		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment1, comment2], at: 0)
		assertThat(sut, isRendering: [comment1, comment2], timeFormatConfiguration: configuration)
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [], timeFormatConfiguration: configuration)
	}
	
	func test_loadImageCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment1 = makeImageComment()
		let configuration = Self.makeTimeFormatConfiguration(date: Date())
		let (sut, loader) = makeSUT(timeFormatConfiguration: configuration)

		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment1], at: 0)
		assertThat(sut, isRendering: [comment1], timeFormatConfiguration: configuration)
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment1], timeFormatConfiguration: configuration)
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
	
	func test_onDeinit_cancelsCommentsLoading() {
		let loader = LoaderSpy(url: anyURL())
		var sut: ImageCommentsViewController?
		
		autoreleasepool {
			sut = ImageCommentsUIComposer.imageCommentsComposedWith(
				imageCommentsLoader: loader.loadPublisher)
			sut?.loadViewIfNeeded()
		}
		
		XCTAssertEqual(loader.cancelledURL.count, 0, "Loading should not be cancelled yet")

		sut = nil
		XCTAssertEqual(loader.cancelledURL.count, 1, "Loading should stop as the image view controller itself is deinitialized")
	}
	
	func test_loadImageCommentsCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()
		
		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeImageCommentsLoading(at: 0)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}
	
	// MARK: - Helper
	
	private func makeSUT(stubURL: URL = anyURL(), timeFormatConfiguration: TimeFormatConfiguration = makeTimeFormatConfiguration(date: Date()), file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy(url: stubURL)
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(imageCommentsLoader: loader.loadPublisher, timeFormatConfiguration: timeFormatConfiguration)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeImageComment(_ date: Date = Date()) -> ImageComment {
		ImageComment(
			id: UUID(),
			message: "a message",
			createdAt: date,
			author: ImageComment.Author(username: "an username"))
	}
	
	private static func makeTimeFormatConfiguration(date: Date) -> TimeFormatConfiguration {
		TimeFormatConfiguration(
			relativeDate: { date },
			locale: Locale(identifier: "en_US_POSIX"))
	}
	
}


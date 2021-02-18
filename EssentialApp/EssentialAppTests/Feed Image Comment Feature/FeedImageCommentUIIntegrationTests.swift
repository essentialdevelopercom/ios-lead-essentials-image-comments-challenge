//
//  FeedImageCommentUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Mario Alberto Barragán Espinosa on 09/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS

class FeedImageCommentUIIntegrationTests: XCTestCase {
	
	func test_feedViewComments_hasTitle() {
		let (sut, _) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("FEED_COMMENT_VIEW_TITLE"))
	}
	
	func test_loadFeedCommentActions_requestFeedCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertTrue(loader.loadedImageCommentURLs.isEmpty, 
					  "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadedImageCommentURLs, [anyURL()], 
					   "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedFeedCommentReload()
		XCTAssertEqual(loader.loadedImageCommentURLs, [anyURL(), anyURL()], 
					   "Expected another loading request once user initiates a reload")
		
		sut.simulateUserInitiatedFeedCommentReload()
		XCTAssertEqual(loader.loadedImageCommentURLs, [anyURL(), anyURL(), anyURL()], 
					   "Expected yet another loading request once user initiates another reload")
	}
	
	func test_loadingFeedCommentIndicator_isVisibleWhileLoadingFeedComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeFeedCommentLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completes successfully")
		
		sut.simulateUserInitiatedFeedCommentReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeFeedCommentLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	}
	
	func test_loadingFeedCommentCompletion_rendersSuccessfullyLoadedComments() {
		let comment0 = makeComment(message: "a message", 
								   creationDate: Date().oneDayAgo(), 
								   authorUsername: "An author name")
		let comment1 = makeComment(message: "another message", 
								   creationDate: Date().oneWeekAgo(),
								   authorUsername: "Another author name")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeFeedCommentLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])
		
		sut.simulateUserInitiatedFeedCommentReload()
		loader.completeFeedCommentLoading(with: [comment0, comment1], at: 1)
		assertThat(sut, isRendering: [comment0, comment1])
	}
	
	func test_loadFeedCommentCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment0 = makeComment()
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeFeedCommentLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [comment0])

		sut.simulateUserInitiatedFeedCommentReload()
		loader.completeFeedCommentLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment0])
	}
	
	// MARK: - Helpers
	
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageCommentViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedImageCommentUIComposer.feedImageCommentComposedWith(feedCommentLoader: loader, 
																		  url: url)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeComment(message: String = "", creationDate: Date = Date(), authorUsername: String = "") -> FeedImageComment {
		return FeedImageComment(id: UUID(), message: message, creationDate: creationDate, authorUsername: authorUsername)
	}
}

private extension Date {
	func oneHourAgo() -> Date {
		return self - 3600
	}
	
	func oneDayAgo() -> Date {
		return adding(days: -1)
	}
	
	func oneWeekAgo() -> Date {
		return adding(days: -7)
	}
	
	private func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}

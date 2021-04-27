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
		let date = Date()
		let comment0 = makeComment(message: "message0", date: (date: date.adding(days: -1), string: "1 day ago"), author: "author0")
		let comment1 = makeComment(message: "message1", date: (date: date.adding(days: -2), string: "2 days ago"), author: "author1")
		let comment2 = makeComment(message: "message2", date: (date: date.adding(days: -31), string: "1 month ago"), author: "author2")
		let comment3 = makeComment(message: "message3", date: (date: date.adding(days: -366), string: "1 year ago"), author: "author3")
		let (sut, loader) = makeSUT(currentDate: { date }, locale: .init(identifier: "en_US_POSIX"))

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeCommentsLoading(with: [comment0.model], at: 0)
		assertThat(sut, isRendering: [comment0.expectedContent])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [comment0.model, comment1.model, comment2.model, comment3.model], at: 1)
		assertThat(sut, isRendering: [comment0.expectedContent, comment1.expectedContent, comment2.expectedContent, comment3.expectedContent])
	}
	
	func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
		let date = Date()
		let comment0 = makeComment(message: "message0", date: (date: date.adding(days: -1), string: "1 day ago"), author: "author0")
		let comment1 = makeComment(message: "message1", date: (date: date.adding(days: -2), string: "2 days ago"), author: "author1")
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [comment0.model, comment1.model], at: 0)
		assertThat(sut, isRendering: [comment0.expectedContent, comment1.expectedContent])
		
		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	// MARK: - Helpers

	private func makeSUT(currentDate: @escaping () -> Date = Date.init, locale: Locale = .current, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = FeedUIComposer.feedCommentsComposedWith(commentLoader: loader.loadPublisher) as! FeedCommentsViewController
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeComment(message: String, date: (date: Date, string: String), author: String) -> (model: FeedComment, expectedContent: FeedCommentCellContent) {
		return (
			FeedComment(id: .init(), message: message, createdAt: date.date, author: .init(username: author)),
			FeedCommentCellContent(message: message, username: author, date: date.string)
		)
	}
	
}

struct FeedCommentCellContent {
	let message: String
	let username: String
	let date: String
}

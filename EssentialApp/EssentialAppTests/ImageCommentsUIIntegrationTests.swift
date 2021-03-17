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
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedComments() {
		let comment1 = makeImageComment()
		let comment2 = makeImageComment()
		let comment3 = makeImageComment()
		let comment4 = makeImageComment()
		let comment5 = makeImageComment()
		let fixedRelativeDate = Date()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [], withRelativeDate: { fixedRelativeDate })
				
		loader.completeImageCommentsLoading(with: [comment1], at: 0)
		assertThat(sut, isRendering: [comment1], withRelativeDate: { fixedRelativeDate })
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoading(with: [comment1, comment2, comment3, comment4, comment5], at: 1)
		assertThat(sut, isRendering: [comment1, comment2, comment3, comment4, comment5], withRelativeDate: { fixedRelativeDate })
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsListAfterNonEmptyResponse() {
		let comment1 = makeImageComment()
		let comment2 = makeImageComment()
		let fixedRelativeDate = Date()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment1, comment2], at: 0)
		assertThat(sut, isRendering: [comment1, comment2], withRelativeDate: { fixedRelativeDate })
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [], withRelativeDate: { fixedRelativeDate })
	}
	
	func test_loadImageCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let comment1 = makeImageComment()
		let fixedRelativeDate = Date()
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment1], at: 0)
		assertThat(sut, isRendering: [comment1], withRelativeDate: { fixedRelativeDate })
		
		sut.simulateUserInitiatedReload()
		loader.completeImageCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [comment1], withRelativeDate: { fixedRelativeDate })
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
	
	func test_imageCommentsView_cancelsCommentsLoadingWhenViewIsNotVisibleAnymore() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.cancelledURL.count, 0, "View should perform loading as normal")

		sut.viewDidDisappear(true)
		XCTAssertEqual(loader.cancelledURL.count, 1, "View should call delegate's method to notify about dismantle")
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
	
	func test_ImageCommentsView_formatCommentCreationDateWithRelativeDate() {
		let commentCreationDate = Date()
		let imageComment = makeImageComment(createdAt: commentCreationDate)
		let expectedLocalizedDateString = "10 seconds ago"
		let fixedRelativeDate = Date().addingTimeInterval(10)
		let (sut, loader) = makeSUT(relativeDate: { fixedRelativeDate })
		
		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [imageComment], at: 0)
		
		let cell = sut.imageCommentView(at: 0) as! ImageCommentCell
		XCTAssertEqual(cell.relativeDateLabel.text, expectedLocalizedDateString, "Expected the date displayed on the cell to always be relative to current date")
	}
	
	// MARK: - Helper
	
	private func makeSUT(stubURL: URL = anyURL(), relativeDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, loader: LoaderSpy) {
		let loader = LoaderSpy(url: stubURL)
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(imageCommentsLoader: loader, relativeDate: relativeDate)
		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(loader, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeImageComment(createdAt date: Date = Date()) -> ImageComment {
		ImageComment(id: UUID(), message: "a message", createdAt: date, author: ImageComment.Author(username: "an username"))
	}
	
}


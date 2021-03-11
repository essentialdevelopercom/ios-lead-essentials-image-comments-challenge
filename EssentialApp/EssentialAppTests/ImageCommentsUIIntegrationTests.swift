//
//  ImageCommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Lukas Bahrle Santana on 27/01/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class ImageCommentsUIIntegrationTests: XCTestCase {
	func test_imageCommentsView_hasTitle() {
		let (sut,_) = makeSUT()
		
		sut.loadViewIfNeeded()
		
		XCTAssertEqual(sut.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}
	
	func test_loadImageCommentsActions_requestImageCommentsFromLoader() {
		let (sut, loader) = makeSUT()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 0, "Expected no loading requests before view is loaded")
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 1, "Expected a loading request once view is loaded")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 2, "Expected another loading request once user initiates a reload")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(loader.loadImageCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
	}
	
	func test_loadingImageCommentsIndicator_isVisibleWhileLoadingImageComments() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
		
		loader.completeImageCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
		
		loader.completeImageCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
		
	}
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedImageComments() {
		let (sut, loader) = makeSUT()
		let currentDate = Date()
		let (comment0, presentable0) = makeImageComment(message: "message0", username: "username0", createdAt: (currentDate.adding(days: -1), "1 day ago"))
		let (comment1, presentable1) = makeImageComment(message: "message1", username: "username1", createdAt: (currentDate.adding(days: -2), "2 days ago"))
		let (comment2, presentable2) = makeImageComment(message: "message2", username: "username2", createdAt: (currentDate.adding(days: -7), "1 week ago"))
		let (comment3, presentable3) = makeImageComment(message: "message3", username: "username3", createdAt: (currentDate.adding(days: -31), "1 month ago"))
		
		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])
		
		loader.completeImageCommentsLoading(with: [comment0], at: 0)
		assertThat(sut, isRendering: [presentable0])
		
		sut.simulateUserInitiatedImageCommentsReload()
		loader.completeImageCommentsLoading(with: [comment0, comment1, comment2, comment3], at: 1)
		assertThat(sut, isRendering: [presentable0, presentable1, presentable2, presentable3])
	}
	
	
	func test_loadImageCommentsCompletion_rendersSuccessfullyLoadedEmptyListAfterNonEmptyImageCommentsList() {
		let currentDate = Date()
		let (comment0, presentable0) = makeImageComment(message: "message0", username: "username0", createdAt: (currentDate.adding(days: -1), "1 day ago"))
		let (comment1, presentable1) = makeImageComment(message: "message1", username: "username1", createdAt: (currentDate.adding(days: -2), "2 days ago"))
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment0, comment1], at: 0)
		assertThat(sut, isRendering: [presentable0, presentable1])
		
		sut.simulateUserInitiatedImageCommentsReload()
		loader.completeImageCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}
	
	func test_loadImageCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let currentDate = Date()
		let (comment0, presentable0) = makeImageComment(message: "message0", username: "username0", createdAt: (currentDate.adding(days: -1), "1 day ago"))
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		loader.completeImageCommentsLoading(with: [comment0], at: 0	)
		assertThat(sut, isRendering: [presentable0])
		
		sut.simulateUserInitiatedImageCommentsReload()
		loader.completeImageCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [presentable0])
	}
	
	func test_loadImageCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()
		
		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage(), nil)
		
		loader.completeImageCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage(), localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR"))
		
		sut.simulateUserInitiatedImageCommentsReload()
		XCTAssertEqual(sut.errorMessage(), nil)
	}
	
	
	func test_cancelCommentsLoading_whenViewIsDeallocated() {
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

	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (ImageCommentsViewController, LoaderSpy) {
		let loader = LoaderSpy()
		let sut = ImageCommentsUIComposer.imageCommentsComposedWith(loader: loader.loadPublisher, currentDate: Date.init, locale: Locale(identifier: "en_us"))
		
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, loader)
	}
	
	private func makeImageComment(message: String, username: String, createdAt: (date: Date, presentable: String)) -> (ImageComment, PresentableImageComment) {
		
		let imageComment = ImageComment(id: UUID(), message: message, createdAt: createdAt.date, author: ImageCommentAuthor(username: username))
		
		let presentableImageComment = PresentableImageComment(message: message, createdAt: createdAt.presentable, username: username)
		
		return (imageComment, presentableImageComment)
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
}








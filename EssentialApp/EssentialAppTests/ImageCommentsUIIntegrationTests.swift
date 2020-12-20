//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Araceli Ruiz Ruiz on 21/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class ImageCommentsUIIntegrationTests: XCTestCase {
    
    func test_ImageCommentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localized("COMMENTS_VIEW_TITLE"))
    }

    func test_loadCommentsActions_requestCommentsfromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallsCount, 0, "Expected no loading requests before view is loaded")
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallsCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(loader.loadCallsCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(loader.loadCallsCount, 3, "Expected yet another loading request once user initiates another")
    }
  
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComents() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes succesfully")
        
        sut.simulateUserInitiatedCommentsReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = ImageComment(id: UUID(), message: "message0", createdAt: Date(), username: "username0")
        let comment1 = ImageComment(id: UUID(), message: "message1", createdAt: Date(), username: "username1")
        let comment2 = ImageComment(id: UUID(), message: "message2", createdAt: Date(), username: "username2")
        let comment3 = ImageComment(id: UUID(), message: "message3", createdAt: Date(), username: "username3")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        let comments = [comment0, comment1, comment2, comment3]
        sut.simulateUserInitiatedCommentsReload()
        loader.completeCommentsLoading(with: comments, at: 1)
        
        assertThat(sut, isRendering: comments)
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment0 = ImageComment(id: UUID(), message: "message0", createdAt: Date(), username: "username0")
        let comment1 = ImageComment(id: UUID(), message: "message1", createdAt: Date(), username: "username1")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 0)
        assertThat(sut, isRendering: [comment0, comment1])

        sut.simulateUserInitiatedCommentsReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment0 = ImageComment(id: UUID(), message: "message0", createdAt: Date(), username: "username0")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedCommentsReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment0])
    }
    
    func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, localized("COMMENTS_VIEW_CONNECTION_ERROR"))
        
        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_viewWillDisappear_cancelsLoadCommentsRequest() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallsCount, 1, "Expected a loading request once view is loaded")
        
        sut.delegate = nil
        XCTAssertEqual(loader.cancelledLoadCallsCount, 1, "Expected cancelled requests after task is cancelled")
    }
    
    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, client: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ImageCommentsUIComposer.imageCommentsComposedWith(url: anyURL(), loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
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

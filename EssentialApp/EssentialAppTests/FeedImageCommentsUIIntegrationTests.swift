//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class FeedImageCommentsUIIntegrationTests: XCTestCase {
    
    func test_commenstView_hasLocalizedTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localized("FEED_COMMENTS_VIEW_TITLE"))
    }
    
    func test_loadCommentsAction_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCount, 2, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")
        
        loader.completeCommentsLoading()
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeCommentsLoading(with: anyNSError())
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comments = makeUniqueComments()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: comments)
        let viewModels = FeedImageCommentsPresenter.map(comments).comments
        assertThat(sut, isRendering: viewModels)
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedCommentsAfterNonEmptyComments() {
        let comments = makeUniqueComments()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: comments)
        let viewModels = FeedImageCommentsPresenter.map(comments).comments
        assertThat(sut, isRendering: viewModels)
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comments = makeUniqueComments()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: comments, at: 0)
        let viewModels = FeedImageCommentsPresenter.map(comments).comments
        assertThat(sut, isRendering: viewModels)
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: anyNSError(), at: 1)
        assertThat(sut, isRendering: viewModels)
    }
    
    func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil, "Expected no error view when view is loaded")
        
        loader.completeCommentsLoading(with: anyNSError(), at: 0)
        XCTAssertEqual(sut.errorMessage, localized("FEED_COMMENTS_VIEW_ERROR_MESSAGE"))
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil, "Expected no error message when user initiates reload")
        
        loader.completeCommentsLoading(with: [], at: 1)
        XCTAssertEqual(sut.errorMessage, nil, "Expected no error when reload completes successfully")
    }
    
    func test_cancelCommentsLoading_whenViewIsDismissed() {
        var sut: FeedImageCommentsViewController?
        let loader = LoaderSpy()
        
        autoreleasepool {
            sut = FeedImageCommentsUIComposer.imageCommentsComposeWith(commentsLoader: loader)
            sut?.loadViewIfNeeded()
        }
        
        XCTAssertEqual(loader.cancelCount, 0, "Expected to has not cancelled requests")

        sut = nil
        XCTAssertEqual(loader.cancelCount, 1, "Expected loading to be cancelled when view is about to disappear")
        
    }
    
    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        let exp = expectation(description: "Wait to load from background")
        
        sut.loadViewIfNeeded()
        
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedImageCommentsViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedImageCommentsUIComposer.imageCommentsComposeWith(commentsLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeUniqueComments() -> [FeedImageComment] {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let comment0 = FeedImageComment(id: UUID(), message: "First message",
                                        createdAt: now.adding(days: -3, calendar: calendar),
                                        author: "Some user name")
        let comment1 = FeedImageComment(id: UUID(), message: "Second message",
                                        createdAt: now.adding(minutes: -5, calendar: calendar), author: "Another user name")
        
        return [comment0, comment1]
    }
}

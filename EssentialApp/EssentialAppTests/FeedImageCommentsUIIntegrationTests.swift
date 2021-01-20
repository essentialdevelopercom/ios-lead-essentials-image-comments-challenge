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
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")
        
        loader.completeCommentsLoading()
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedCommentsReload()
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
        assertThat(sut, isRendering: comments.toModels())
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedCommentsAfterNonEmptyComments() {
        let comments = makeUniqueComments()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: comments)
        assertThat(sut, isRendering: comments.toModels())
        
        sut.simulateUserInitiatedCommentsReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadCommentsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comments = makeUniqueComments()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: comments, at: 0)
        assertThat(sut, isRendering: comments.toModels())
        
        sut.simulateUserInitiatedCommentsReload()
        loader.completeCommentsLoading(with: anyNSError(), at: 1)
        assertThat(sut, isRendering: comments.toModels())
    }
    
    func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoading(with: anyNSError())
        XCTAssertEqual(sut.errorMessage, localized("FEED_COMMENTS_VIEW_ERROR_MESSAGE"))
        
        sut.simulateUserInitiatedCommentsReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_cancelCommentsLoading_whenViewIsDismissed() {
        var sut: FeedImageCommentsViewController?
        let loader = LoaderSpy()
        
        autoreleasepool {
            sut = FeedImageCommentsUIComposer.imageCommentsComposeWith(commentsLoader: loader, url: anyURL())
            sut?.loadViewIfNeeded()
        }
        
        XCTAssertEqual(loader.cancelledRequests.count, 0, "Expected to has not cancelled requests")

        sut = nil
        XCTAssertEqual(loader.cancelledRequests.count, 1, "Expected loading to be cancelled when view is about to disappear")
        
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
        let url = anyURL()
        let loader = LoaderSpy()
        let sut = FeedImageCommentsUIComposer.imageCommentsComposeWith(commentsLoader: loader, url: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeUniqueComments() -> [FeedImageComment] {
        let currentDate = Date()
        let comment0 = FeedImageComment(id: UUID(), message: "First message", createdAt: currentDate.adding(days: -3), author: "Some user name")
        let comment1 = FeedImageComment(id: UUID(), message: "Second message", createdAt: currentDate.adding(seconds: -305), author: "Another user name")
        
        return [comment0, comment1]
    }
}

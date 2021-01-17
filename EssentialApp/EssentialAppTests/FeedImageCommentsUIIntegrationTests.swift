//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialApp
import EssentialFeed
import EssentialFeediOS

final class FeedImageCommentsUIIntegrationTests: XCTestCase {
    
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

class LoaderSpy: FeedImageCommentsLoader {
    var completions = [(FeedImageCommentsLoader.Result) -> Void]()
    var loadCommentsCallCount: Int {
        return completions.count
    }
    
    private struct Task: FeedImageCommentsLoaderTask {
        func cancel() {}
    }
    
    func load(from url: URL, completion: @escaping (FeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
        completions.append(completion)
        return Task()
    }
    
    func completeCommentsLoading(with comments: [FeedImageComment] = [], at index: Int = 0) {
        completions[index](.success(comments))
    }
    
    func completeCommentsLoading(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
}

extension FeedImageCommentsViewController {
     func simulateUserInitiatedCommentsReload() {
         refreshControl?.simulatePullToRefresh()
     }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedCommentsViews() -> Int {
        return tableView.numberOfRows(inSection: commentsSection)
    }
    
    func commentView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedCommentsViews() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var commentsSection: Int {
        return 0
    }
}

extension FeedImageCommentsUIIntegrationTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "FeedImageComments"
        let bundle = Bundle(for: FeedImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

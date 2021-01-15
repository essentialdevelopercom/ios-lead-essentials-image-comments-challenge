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
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeCommentsLoading()
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
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
}

class LoaderSpy: FeedImageCommentsLoader {
    var loadCommentsCallCount = 0
    var completions = [(FeedImageCommentsLoader.Result) -> Void]()
    
    private struct Task: FeedImageCommentsLoaderTask {
        func cancel() {}
    }
    
    func load(from url: URL, completion: @escaping (FeedImageCommentsLoader.Result) -> Void) -> FeedImageCommentsLoaderTask {
        loadCommentsCallCount += 1
        completions.append(completion)
        return Task()
    }
    
    func completeCommentsLoading(at index: Int = 0) {
        completions[index](.success([]))
    }
}

extension FeedImageCommentsViewController {
     func simulateUserInitiatedCommentsReload() {
         refreshControl?.simulatePullToRefresh()
     }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
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



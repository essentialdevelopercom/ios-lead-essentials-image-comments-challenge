//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Araceli Ruiz Ruiz on 21/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class ImageCommentsViewController: UITableViewController {
    private var loader: ImageCommentsLoader?
    
    convenience init(loader: ImageCommentsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load() {
        _ = loader?.loadComments() { _ in }
    }
}

final class ImageCommentsViewControllerTests: XCTestCase {

    func test_init_doesNotLoadComments() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallsCount, 0)
    }
    
    func test_viewDidLoad_loadsComments() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallsCount, 1)
    }
    
    func test_pullToRefresh_loadsComments() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallsCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallsCount, 3)

    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCommentsViewController, client: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = ImageCommentsViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: ImageCommentsLoader {
        private(set) var loadCallsCount = 0
        
        private struct TaskSpy: ImageCommentsLoaderTask {
            func cancel() {}
        }
        
        func loadComments(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
            loadCallsCount += 1
            return TaskSpy()
        }

    }

}


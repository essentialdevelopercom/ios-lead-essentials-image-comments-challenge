//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Araceli Ruiz Ruiz on 21/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class ImageCommentsViewController: UIViewController {
    private var loader: ImageCommentsLoader?
    
    convenience init(loader: ImageCommentsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        let url = URL(string: "http://any-url.com")!
        _ = loader?.loadComments(from: url) { _ in }
    }
    
}

final class ImageCommentsViewControllerTests: XCTestCase {

    func test_init_doesNotLoadComments() {
        let loader = LoaderSpy()
        _ = ImageCommentsViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallsCount, 0)
    }
    
    func test_viewDidLoad_loadsComments() {
        let loader = LoaderSpy()
        let sut = ImageCommentsViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallsCount, 1)
    }

    
    // MARK: - Helpers
    
    class LoaderSpy: ImageCommentsLoader {
        private(set) var loadCallsCount = 0
        
        private struct TaskSpy: ImageCommentsLoaderTask {
            func cancel() {}
        }
        
        func loadComments(from url: URL, completion: @escaping (ImageCommentsLoader.Result) -> Void) -> ImageCommentsLoaderTask {
            loadCallsCount += 1
            return TaskSpy()
        }

    }

}

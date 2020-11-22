//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Araceli Ruiz Ruiz on 21/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest

final class ImageCommentsViewController: UIViewController {
    private var loader: ImageCommentsViewControllerTests.LoaderSpy?
    
    convenience init(loader: ImageCommentsViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        loader?.load()
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
    
    class LoaderSpy {
        private(set) var loadCallsCount = 0
        
        func load() {
            loadCallsCount += 1
        }
    }

}

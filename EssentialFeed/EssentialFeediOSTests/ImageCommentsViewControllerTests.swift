//
//  ImageCommentsViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Araceli Ruiz Ruiz on 21/11/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest

final class ImageCommentsViewController {
    
    init(loader: Any) {}
}

final class ImageCommentsViewControllerTests: XCTestCase {

    func test_init_doesNotLoadComments() {
        let loader = LoaderSpy()
        _ = ImageCommentsViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallsCount, 0)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallsCount = 0
    }

}

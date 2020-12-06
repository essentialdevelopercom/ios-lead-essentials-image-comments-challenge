//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Araceli Ruiz Ruiz on 06/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest

final class ImageCommentsPresenter {
    
    init(view: Any) {
        
    }
}

class ImageCommentsPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        _ = ImageCommentsPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    private class ViewSpy {
        private(set) var messages = [Any]()
    }
}

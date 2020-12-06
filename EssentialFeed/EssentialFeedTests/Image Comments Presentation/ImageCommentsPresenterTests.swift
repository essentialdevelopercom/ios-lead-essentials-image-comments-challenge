//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Araceli Ruiz Ruiz on 06/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest

protocol ImageCommentsView {
    func display(errorMesagge: String?)
}

final class ImageCommentsPresenter {
    private let view: ImageCommentsView
    
    init(view: ImageCommentsView) {
        self.view = view
    }
    
    func didStartLoadingComments() {
        view.display(errorMesagge: nil)
    }
}

class ImageCommentsPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
       
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingComments_displaysNoErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingComments()

        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = ImageCommentsPresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    
    private class ViewSpy: ImageCommentsView {
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        private(set) var messages = [Message]()
        
        func display(errorMesagge: String?) {
            messages.append(.display(errorMessage: errorMesagge))
        }
    }
}

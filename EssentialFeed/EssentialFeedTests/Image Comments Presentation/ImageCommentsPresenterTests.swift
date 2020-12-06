//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Araceli Ruiz Ruiz on 06/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest

struct ImageCommentsLoadingViewModel {
    let isLoading: Bool
}

protocol ImageCommentsLoadingView {
    func display(_ viewModel: ImageCommentsLoadingViewModel)
}

struct ImageCommentsErrorViewModel {
    let message: String?
    
    static var noError: ImageCommentsErrorViewModel {
        return ImageCommentsErrorViewModel(message: nil)
    }
}

protocol ImageCommentsErrorView {
    func display(_ viewModel: ImageCommentsErrorViewModel)
}

final class ImageCommentsPresenter {
    private let loadingView: ImageCommentsLoadingView
    private let errorView: ImageCommentsErrorView
    
    init(loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingComments() {
        errorView.display(.noError)
        loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
    }
}

class ImageCommentsPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
       
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingComments()

        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = ImageCommentsPresenter(loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    
    private class ViewSpy: ImageCommentsLoadingView, ImageCommentsErrorView {
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: ImageCommentsLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: ImageCommentsErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}

//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Araceli Ruiz Ruiz on 06/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("COMMENTS_VIEW_TITLE"))
    }
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
       
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingComments_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingComments()

        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    func test_didFinishLoadingComments_displaysCommentsAndStopLoading() {
		let date = { Date(timeIntervalSince1970: 1609157640) }
        let (sut, view) = makeSUT(date: date)
        
        let comments = [
			ImageComment(
				id: UUID(),
				message: "message0",
				createdAt: Date(timeIntervalSince1970: 1609157580),
				username: "username0"
			),
			ImageComment(
				id: UUID(),
				message: "message1",
				createdAt: Date(timeIntervalSince1970: 1609154040),
				username: "username1"
			)
		]
		
		let viewModels = [
			ImageCommentViewModel(
				message: "message0",
				date: "1 minute ago",
				username: "username0"
			),
			ImageCommentViewModel(
				message: "message1",
				date: "1 hour ago",
				username: "username1")
		]
		
        sut.didFinishLoadingComments(with: comments)
        
		XCTAssertEqual(view.messages, [.display(comments: viewModels), .display(isLoading: false)])
    }
    
    func test_didFinishLoadingCommentsWithError_displaysLocalizedErrorMessageAndStopLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingComments(with: anyNSError())
        
        XCTAssertEqual(view.messages, [.display(errorMessage: localized("COMMENTS_VIEW_CONNECTION_ERROR")),
                                       .display(isLoading: false)])
    }


    // MARK: - Helpers
    
	private func makeSUT(date: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = ImageCommentsPresenter(imageCommentsView: view, loadingView: view, errorView: view, date: date)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

    private class ViewSpy: ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView {
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(comments: [ImageCommentViewModel])
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: ImageCommentsViewModel) {
            messages.append(.display(comments: viewModel.comments))
        }
        
        func display(_ viewModel: ImageCommentsLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: ImageCommentsErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}

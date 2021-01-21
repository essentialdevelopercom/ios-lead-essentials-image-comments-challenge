//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedImageCommentsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedImageCommentsPresenter.title, localized("FEED_COMMENTS_VIEW_TITLE"))
    }
    
    func test_init_doesNotSendMessagesToView() {
        let (_ , view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingComments_displaysNoErrorMessagesAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingComments()

        XCTAssertEqual(view.messages, [.display(errorMessage: nil), .display(isLoading: true)])
    }

    func test_didFinishLoadingComments_displaysCommentsAndStopsLoading() {
        let (sut, view) = makeSUT()
        let comments = [
            FeedImageComment(id: UUID(), message: "a message", createdAt: Date().adding(seconds: -40), author: "a username"),
            FeedImageComment(id: UUID(), message: "another message", createdAt: Date().adding(seconds: -60 * 60), author: "another username")
        ]
        
        let presentedComments = [
            FeedImageCommentPresenterModel(username: "a username", creationTime: "40 seconds ago", comment: "a message"),
            FeedImageCommentPresenterModel(username: "another username", creationTime: "1 hour ago", comment: "another message")
        ]
        
        sut.didFinishLoadingComments(with: comments)
        XCTAssertEqual(view.messages, [.display(comments: presentedComments), .display(isLoading: false)])
    }
    
    func test_didFinishLoadingCommentsWithError_displaysErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        let error = anyNSError()

        sut.didFinishLoadingComments(with: error)
        print(view.messages)

        XCTAssertEqual(view.messages, [.display(errorMessage: localized("FEED_COMMENTS_VIEW_ERROR_MESSAGE")), .display(isLoading: false)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(date: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (FeedImageCommentsPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImageCommentsPresenter(commentsView: view, loadingView: view, errorView: view)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        
        return (sut, view)
    }
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "FeedImageComments"
        let bundle = Bundle(for: FeedImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    private class ViewSpy: FeedImageCommentsView, FeedImageCommentsLoadingView, FeedImageCommentsErrorView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(comments: [FeedImageCommentPresenterModel])
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedImageCommentsLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedImageCommentsErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedImageCommentsViewModel) {
            messages.insert(.display(comments: viewModel.comments))
        }
    }
}

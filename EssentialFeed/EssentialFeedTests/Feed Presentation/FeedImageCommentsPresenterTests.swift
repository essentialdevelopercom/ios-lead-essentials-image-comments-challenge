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
        let view = ViewSpy()
        _ = FeedImageCommentsPresenter(loadingView: view, errorView: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingComments_displaysNoErrorMessagesAndStartsLoading() {
        let view = ViewSpy()
        let sut = FeedImageCommentsPresenter(loadingView: view, errorView: view)
        
        sut.didStartLoadingComments()

        XCTAssertEqual(view.messages, [.display(errorMessage: nil), .display(isLoading: true)])
    }
    
    
    // MARK: - Helpers
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "FeedImageComments"
        let bundle = Bundle(for: FeedImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    private class ViewSpy: FeedImageCommentsLoadingView, FeedImageCommentsErrorView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages = Set<Message>()
        
        func display(isLoading: Bool) {
            messages.insert(.display(isLoading: isLoading))
        }
        
        func display(errorMessage: String?) {
            messages.insert(.display(errorMessage: errorMessage))
        }
    }
}

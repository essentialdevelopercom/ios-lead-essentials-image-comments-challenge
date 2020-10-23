//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

protocol ImageCommentsLoadingView {
    func display(isLoading: Bool)
}

protocol ImageCommentsErrorView {
    func display(errorMessage: String?)
}

protocol ImageCommentsView {
    func display(comments: [ImageComment])
}

class ImageCommentsPresenter {
    let imageCommentsView: ImageCommentsView
    let loadingView: ImageCommentsLoadingView
    let errorView: ImageCommentsErrorView

    public static var title: String { NSLocalizedString(
        "IMAGE_COMMENTS_VIEW_TITLE",
        tableName: "ImageComments",
        bundle: Bundle(for: ImageCommentsPresenter.self),
        comment: "Title for the image comments view"
    ) }

    init(imageCommentsView: ImageCommentsView, loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
        self.imageCommentsView = imageCommentsView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    func didStartLoadingComments() {
        loadingView.display(isLoading: true)
        errorView.display(errorMessage: nil)
    }

    func didFinishLoading(with comments: [ImageComment]) {
        imageCommentsView.display(comments: comments)
        loadingView.display(isLoading: false)
    }
}

final class ImageCommentsPresenterTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty)
    }

    func test_didStartLoadingComments_displaysNoErrorMessagesAndStartsLoading() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingComments()

        XCTAssertEqual(view.messages, [.display(errorMessage: nil), .display(isLoading: true)])
    }

    func test_didFinishLoadingComments_displaysCommentsAndStopsLoading() {
        let (sut, view) = makeSUT()
        let comments = uniqueComments()
        sut.didFinishLoading(with: comments)

        XCTAssertEqual(view.messages, [.display(comments: comments), .display(isLoading: false)])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (ImageCommentsPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = ImageCommentsPresenter(imageCommentsView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    private func uniqueComments() -> [ImageComment] {
        [
            ImageComment(
                id: UUID(),
                message: "a message",
                createdAt: anyDate(),
                author: "a username"
            ),
            ImageComment(
                id: UUID(),
                message: "another message",
                createdAt: anyDate(),
                author: "another username"
            ),
        ]
    }
    
    private func anyDate() -> Date {
        Date(timeIntervalSince1970: 1603416829)
    }

    private class ViewSpy: ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(comments: [ImageComment])
        }

        private(set) var messages = Set<Message>()

        func display(comments: [ImageComment]) {
            messages.insert(.display(comments: comments))
        }

        func display(isLoading: Bool) {
            messages.insert(.display(isLoading: isLoading))
        }

        func display(errorMessage: String?) {
            messages.insert(.display(errorMessage: errorMessage))
        }
    }
}

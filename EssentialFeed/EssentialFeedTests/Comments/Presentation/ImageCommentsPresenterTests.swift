//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

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
        let fixedDate = Date(timeIntervalSince1970: 1603497600) // 24 OCT 2020 - 00:00:00
        let (sut, view) = makeSUT(date: fixedDate, locale: Locale(identifier: "en_US"))
        let comments = [
            ImageComment(
                id: UUID(),
                message: "first message",
                createdAt: Date(timeIntervalSince1970: 1603411200),
                author: "first username"
            ), // 23 OCT 2020 - 00:00:00
            ImageComment(
                id: UUID(),
                message: "second message",
                createdAt: Date(timeIntervalSince1970: 1603494000),
                author: "second username"
            ), // 23 OCT 2020 - 23:00:00
            ImageComment(
                id: UUID(),
                message: "third message",
                createdAt: Date(timeIntervalSince1970: 1603495800),
                author: "third username"
            ), // 23 OCT 2020 - 23:30:00
            ImageComment(
                id: UUID(),
                message: "fourth message",
                createdAt: Date(timeIntervalSince1970: 1603497590),
                author: "fourth username"
            ), // 23 OCT 2020 - 23:59:50
            ImageComment(
                id: UUID(),
                message: "fifth message",
                createdAt: Date(timeIntervalSince1970: 1602892800),
                author: "fifth username"
            ), // 17 OCT 2020 - 00:00:00
            ImageComment(
                id: UUID(),
                message: "sixth message",
                createdAt: Date(timeIntervalSince1970: 1600300800),
                author: "sixth username"
            ), // 17 SEP 2020 - 00:00:00
        ]

        let presentableComments = [
            PresentableImageComment(username: "first username", createdAt: "1 day ago", message: "first message"),
            PresentableImageComment(username: "second username", createdAt: "1 hour ago", message: "second message"),
            PresentableImageComment(username: "third username", createdAt: "30 minutes ago", message: "third message"),
            PresentableImageComment(username: "fourth username", createdAt: "10 seconds ago", message: "fourth message"),
            PresentableImageComment(username: "fifth username", createdAt: "1 week ago", message: "fifth message"),
            PresentableImageComment(username: "sixth username", createdAt: "1 month ago", message: "sixth message"),
        ]

        sut.didFinishLoading(with: comments)

        XCTAssertEqual(view.messages, [.display(comments: presentableComments), .display(isLoading: false)])
    }

    func test_didFinishLoadingCommentsWithError_displaysErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        let error = anyNSError()

        sut.didFinishLoading(with: error)

        XCTAssertEqual(
            view.messages, [
                .display(errorMessage: localized("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR")),
                .display(isLoading: false),
            ]
        )
    }

    // MARK: - Helpers

    private func makeSUT(
        date: Date = Date(),
        locale: Locale = .current,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (ImageCommentsPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = ImageCommentsPresenter(imageCommentsView: view, loadingView: view, errorView: view, currentDate: date, locale: locale)
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
            case display(comments: [PresentableImageComment])
        }

        private(set) var messages = Set<Message>()

        func display(_ viewModel: ImageCommentsViewModel) {
            messages.insert(.display(comments: viewModel.comments))
        }

        func display(_ viewModel: ImageCommentsLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }

        func display(_ viewModel: ImageCommentsErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.errorMessage))
        }
    }
}

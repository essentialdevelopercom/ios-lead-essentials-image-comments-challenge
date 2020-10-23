//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest

protocol ImageCommentsLoadingView {
    func display(isLoading: Bool)
}

protocol ImageCommentsErrorView {
    func display(errorMessage: String?)
}

class ImageCommentsPresenter {
    let loadingView: ImageCommentsLoadingView
    let errorView: ImageCommentsErrorView

    public static var title: String { NSLocalizedString(
        "IMAGE_COMMENTS_VIEW_TITLE",
        tableName: "ImageComments",
        bundle: Bundle(for: ImageCommentsPresenter.self),
        comment: "Title for the image comments view"
    ) }

    init(loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
        self.loadingView = loadingView
        self.errorView = errorView
    }

    func didStartLoadingComments() {
        loadingView.display(isLoading: true)
        errorView.display(errorMessage: nil)
    }
}

final class ImageCommentsPresenterTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }

    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        _ = ImageCommentsPresenter(loadingView: view, errorView: view)

        XCTAssertTrue(view.messages.isEmpty)
    }

    func test_didStartLoadingComments_displaysNoErrorMessagesAndStartsLoading() {
        let view = ViewSpy()
        let sut = ImageCommentsPresenter(loadingView: view, errorView: view)

        sut.didStartLoadingComments()

        XCTAssertEqual(view.messages, [.display(errorMessage: nil), .display(isLoading: true)])
    }

    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

    private class ViewSpy: ImageCommentsLoadingView, ImageCommentsErrorView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }

        var messages = Set<Message>()

        func display(isLoading: Bool) {
            messages.insert(.display(isLoading: isLoading))
        }

        func display(errorMessage: String?) {
            messages.insert(.display(errorMessage: errorMessage))
        }
    }
}

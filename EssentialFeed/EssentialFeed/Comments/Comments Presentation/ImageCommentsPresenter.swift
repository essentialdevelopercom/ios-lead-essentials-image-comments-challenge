//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsLoadingView {
    func display(_ viewModel: ImageCommentsLoadingViewModel)
}

public protocol ImageCommentsErrorView {
    func display(_ viewModel: ImageCommentsErrorViewModel)
}

public protocol ImageCommentsView {
    func display(_ viewModel: ImageCommentsViewModel)
}

public class ImageCommentsPresenter {
    private let locale: Locale
    private let calendar = Calendar(identifier: .gregorian)
    private let imageCommentsView: ImageCommentsView
    private let loadingView: ImageCommentsLoadingView
    private let errorView: ImageCommentsErrorView
    private let currentDate: () -> Date

    public static var title: String { NSLocalizedString(
        "IMAGE_COMMENTS_VIEW_TITLE",
        tableName: "ImageComments",
        bundle: Bundle(for: ImageCommentsPresenter.self),
        comment: "Title for the image comments view"
    ) }

    private var errorMessage: String {
        NSLocalizedString(
            "IMAGE_COMMENTS_VIEW_CONNECTION_ERROR",
            tableName: "ImageComments",
            bundle: Bundle(for: ImageCommentsPresenter.self),
            comment: "Error message when loading comments fails"
        )
    }

    public init(
        imageCommentsView: ImageCommentsView,
        loadingView: ImageCommentsLoadingView,
        errorView: ImageCommentsErrorView,
        currentDate: @escaping () -> Date = Date.init,
        locale: Locale = .current
    ) {
        self.imageCommentsView = imageCommentsView
        self.loadingView = loadingView
        self.errorView = errorView
        self.currentDate = currentDate
        self.locale = locale
    }

    public func didStartLoadingComments() {
        loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
        errorView.display(.noError())
    }

    public func didFinishLoading(with comments: [ImageComment]) {
        let presentableComments = comments.map {
            PresentableImageComment(username: $0.author, createdAt: formatDate(since: $0.createdAt), message: $0.message)
        }
        imageCommentsView.display(ImageCommentsViewModel(comments: presentableComments))
        loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
    }

    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: errorMessage))
        loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
    }

    private func formatDate(since date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = locale
        formatter.calendar = calendar
        return formatter.localizedString(for: date, relativeTo: currentDate())
    }
}

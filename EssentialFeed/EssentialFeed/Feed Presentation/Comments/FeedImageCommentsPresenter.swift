//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentsView {
    func display(_ viewModel: FeedImageCommentsViewModel)
}

public protocol FeedImageCommentsLoadingView {
    func display(_ viewModel: FeedImageCommentsLoadingViewModel)
}

public protocol FeedImageCommentsErrorView {
    func display(_ viewModel: FeedImageCommentsErrorViewModel)
}

public final class FeedImageCommentsPresenter {
    let commentsView: FeedImageCommentsView
    let loadingView: FeedImageCommentsLoadingView
    let errorView: FeedImageCommentsErrorView
    let currentDate: () -> Date
    
    public static var title: String {
        return NSLocalizedString("FEED_COMMENTS_VIEW_TITLE",
        tableName: "FeedImageComments",
        bundle: Bundle(for: FeedImageCommentsPresenter.self),
        comment: "Title for the image comments view")
    }
    
    private var errorMessage: String {
        return NSLocalizedString("FEED_COMMENTS_VIEW_ERROR_MESSAGE",
        tableName: "FeedImageComments",
        bundle: Bundle(for: FeedImageCommentsPresenter.self),
        comment: "Error message when loading comments fails")
    }
    
    public init(commentsView: FeedImageCommentsView, loadingView: FeedImageCommentsLoadingView, errorView: FeedImageCommentsErrorView, currentDate: @escaping () -> Date = Date.init) {
        self.commentsView = commentsView
        self.loadingView = loadingView
        self.errorView = errorView
        self.currentDate = currentDate
    }
    
    public func didStartLoadingComments() {
        loadingView.display(FeedImageCommentsLoadingViewModel(isLoading: true))
        errorView.display(.noError)
    }
    
    
    public func didFinishLoadingComments(with comments: [FeedImageComment]) {
        commentsView.display(FeedImageCommentsViewModel(comments: comments.toModels()))
        loadingView.display(FeedImageCommentsLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingComments(with error: Error) {
        errorView.display(.error(message: errorMessage))
        loadingView.display(FeedImageCommentsLoadingViewModel(isLoading: false))
    }
}

public extension Array where Element == FeedImageComment {
    func toModels() -> [FeedImageCommentPresenterModel] {
        map { FeedImageCommentPresenterModel(username: $0.author, creationTime: $0.createdAt.timeAgoDisplay(), comment: $0.message) }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = .current
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

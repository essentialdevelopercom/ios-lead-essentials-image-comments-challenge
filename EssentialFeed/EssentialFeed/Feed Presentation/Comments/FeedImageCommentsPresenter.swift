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
    
    public init(commentsView: FeedImageCommentsView, loadingView: FeedImageCommentsLoadingView, errorView: FeedImageCommentsErrorView) {
        self.commentsView = commentsView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingComments() {
        loadingView.display(FeedImageCommentsLoadingViewModel(isLoading: true))
        errorView.display(.noError)
    }
    
    
    public func didFinishLoadingComments(with comments: [FeedImageComment]) {
        commentsView.display(FeedImageCommentsPresenter.map(comments))
        loadingView.display(FeedImageCommentsLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingComments(with error: Error) {
        errorView.display(.error(message: errorMessage))
        loadingView.display(FeedImageCommentsLoadingViewModel(isLoading: false))
    }
    
    public static func map(_ comments: [FeedImageComment],
        currentDate: Date = Date(), calendar: Calendar = .current, locale: Locale = .current) -> FeedImageCommentsViewModel {
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = locale
        formatter.calendar = calendar
        
        return FeedImageCommentsViewModel(comments: comments.map { comment in
            FeedImageCommentPresenterModel(
                username: comment.author,
                creationTime: formatter.localizedString(for: comment.createdAt, relativeTo: currentDate),
                comment: comment.message)
        })
    }
}

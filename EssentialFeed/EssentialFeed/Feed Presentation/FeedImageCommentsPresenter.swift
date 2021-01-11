//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public struct FeedImageCommentsViewModel {
    public let comments: [FeedImageComment]
}
public protocol FeedImageCommentsView {
    func display(_ viewModel: FeedImageCommentsViewModel)
}

public struct FeedImageCommentsLoadingViewModel {
    public let isLoading: Bool
}

public protocol FeedImageCommentsLoadingView {
    func display(_ viewModel: FeedImageCommentsLoadingViewModel)
}

public struct FeedImageCommentsErrorViewModel {
    public let errorMessage: String?
}

public protocol FeedImageCommentsErrorView {
    func display(_ viewModel: FeedImageCommentsErrorViewModel)
}

public final class FeedImageCommentsPresenter {
    let commentsView: FeedImageCommentsView
    let loadingView: FeedImageCommentsLoadingView
    let errorView: FeedImageCommentsErrorView
    
    public static var title: String { NSLocalizedString(
        "FEED_COMMENTS_VIEW_TITLE",
        tableName: "FeedImageComments",
        bundle: Bundle(for: FeedImageCommentsPresenter.self),
        comment: "Title for the image comments view"
    )}
    
    private var errorMessage: String { NSLocalizedString(
        "FEED_COMMENTS_VIEW_ERROR_MESSAGE",
        tableName: "FeedImageComments",
        bundle: Bundle(for: FeedImageCommentsPresenter.self),
        comment: "Error message when loading comments fails"
    )}
    
    public init(commentsView: FeedImageCommentsView, loadingView: FeedImageCommentsLoadingView, errorView: FeedImageCommentsErrorView) {
        self.commentsView = commentsView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingComments() {
        loadingView.display(FeedImageCommentsLoadingViewModel(isLoading: true))
        errorView.display(FeedImageCommentsErrorViewModel(errorMessage: nil))
    }
    
    
    public func didFinishLoadingComments(with comments: [FeedImageComment]) {
        commentsView.display(FeedImageCommentsViewModel(comments: comments))
        loadingView.display(FeedImageCommentsLoadingViewModel(isLoading: false))
    }
    
    public func didStartLoadingComments(with error: Error) {
        errorView.display(FeedImageCommentsErrorViewModel(errorMessage: errorMessage))
        loadingView.display(FeedImageCommentsLoadingViewModel(isLoading: false))
    }
}

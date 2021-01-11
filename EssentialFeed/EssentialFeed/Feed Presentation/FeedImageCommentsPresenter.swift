//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentsView {
    func display(comments: [FeedImageComment])
}

public protocol FeedImageCommentsLoadingView {
     func display(isLoading: Bool)
 }

 public protocol FeedImageCommentsErrorView {
     func display(errorMessage: String?)
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
        )
     }
    
    private var errorMessage: String { NSLocalizedString(
            "FEED_COMMENTS_VIEW_ERROR_MESSAGE",
            tableName: "ImageComments",
            bundle: Bundle(for: FeedImageCommentsPresenter.self),
            comment: "Error message when loading comments fails"
        )
    }
    
    public init(commentsView: FeedImageCommentsView, loadingView: FeedImageCommentsLoadingView, errorView: FeedImageCommentsErrorView) {
        self.commentsView = commentsView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingComments() {
        loadingView.display(isLoading: true)
        errorView.display(errorMessage: nil)
    }
    
    
    public func didFinishLoadingComments(with comments: [FeedImageComment]) {
        commentsView.display(comments: comments)
        loadingView.display(isLoading: false)
    }
    
    public func didFinishLoading(with error: Error) {
        errorView.display(errorMessage: errorMessage)
        loadingView.display(isLoading: false)
    }
 }

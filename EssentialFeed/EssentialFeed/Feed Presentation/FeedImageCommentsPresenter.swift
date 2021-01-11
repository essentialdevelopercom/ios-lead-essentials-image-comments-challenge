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
     ) }
    
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
 }

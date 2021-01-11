//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentsLoadingView {
     func display(isLoading: Bool)
 }

 public protocol FeedImageCommentsErrorView {
     func display(errorMessage: String?)
 }

public final class FeedImageCommentsPresenter {
    let loadingView: FeedImageCommentsLoadingView
    let errorView: FeedImageCommentsErrorView

     public static var title: String { NSLocalizedString(
         "FEED_COMMENTS_VIEW_TITLE",
         tableName: "FeedImageComments",
         bundle: Bundle(for: FeedImageCommentsPresenter.self),
         comment: "Title for the image comments view"
     ) }
    
    public init(loadingView: FeedImageCommentsLoadingView, errorView: FeedImageCommentsErrorView) {
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public func didStartLoadingComments() {
        loadingView.display(isLoading: true)
        errorView.display(errorMessage: nil)
    }
 }

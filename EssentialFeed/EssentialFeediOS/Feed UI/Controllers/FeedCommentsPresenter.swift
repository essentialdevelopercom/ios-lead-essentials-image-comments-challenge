//
//  Created by Azamat Valitov on 20.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

public protocol FeedCommentsView {
	func display(_ viewModel: FeedCommentsViewModel)
}

public protocol FeedCommentsLoadingView {
	func display(_ viewModel: FeedCommentsLoadingViewModel)
}

public protocol FeedCommentsErrorView {
	func display(_ viewModel: FeedCommentsErrorViewModel)
}

public final class FeedCommentsPresenter {
	
	private let feedCommentsView: FeedCommentsView
	private let loadingView: FeedCommentsLoadingView
	private let errorView: FeedCommentsErrorView
	
	public init(feedCommentsView: FeedCommentsView, loadingView: FeedCommentsLoadingView, errorView: FeedCommentsErrorView) {
		self.feedCommentsView = feedCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public static var title: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_TITLE",
			 tableName: "FeedComments",
			 bundle: Bundle(for: FeedCommentsPresenter.self),
			 comment: "Title for feed comments view")
	}
	
	public func didStartLoadingFeedComments() {
		errorView.display(.noError)
		loadingView.display(FeedCommentsLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingFeedComments(with comments: [FeedComment]) {
		feedCommentsView.display(FeedCommentsViewModel(comments: comments.toViewModels))
		loadingView.display(FeedCommentsLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingFeedComments(with error: Error) {
		errorView.display(.error(message: commentsLoadError))
		loadingView.display(FeedCommentsLoadingViewModel(isLoading: false))
	}
	
	private var commentsLoadError: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_CONNECTION_ERROR",
			 tableName: "FeedComments",
			 bundle: Bundle(for: FeedCommentsPresenter.self),
			 comment: "Error text for comments loading problem")
	}
}

extension Array where Element == FeedComment {
	var toViewModels: [FeedCommentViewModel] {
		map({FeedCommentViewModel(name: $0.authorName, message: $0.message, formattedDate: Self.formatter.localizedString(for: $0.date, relativeTo: Date()))})
	}
	
	private static let formatter = RelativeDateTimeFormatter()
}
 

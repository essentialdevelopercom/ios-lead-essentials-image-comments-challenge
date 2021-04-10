//
//  Created by Azamat Valitov on 21.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedCommentsView {
	func display(_ viewModel: FeedCommentsViewModel)
}

public protocol FeedCommentsLoadingView {
	func display(_ viewModel: FeedCommentsLoadingViewModel)
}

public protocol FeedCommentsErrorView {
	func display(_ viewModel: FeedCommentsErrorViewModel)
}

public class FeedCommentsPresenter {
	
	private let feedCommentsView: FeedCommentsView
	private let loadingView: FeedCommentsLoadingView
	private let errorView: FeedCommentsErrorView
	private let locale: Locale
	
	public init(feedCommentsView: FeedCommentsView, loadingView: FeedCommentsLoadingView, errorView: FeedCommentsErrorView, locale: Locale = Locale.current) {
		self.feedCommentsView = feedCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
		self.locale = locale
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
		feedCommentsView.display(FeedCommentsViewModel(comments: Self.convertToViewModels(comments: comments, locale: locale)))
		loadingView.display(FeedCommentsLoadingViewModel(isLoading: false))
	}
	
	public static func convertToViewModels(comments: [FeedComment], locale: Locale) -> [FeedCommentViewModel] {
		let timeFormatter = RelativeDateTimeFormatter()
		timeFormatter.locale = locale
		return comments.toViewModels(formatter: timeFormatter)
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

private extension Array where Element == FeedComment {
	func toViewModels(formatter: RelativeDateTimeFormatter) -> [FeedCommentViewModel] {
		map({FeedCommentViewModel(name: $0.authorName, message: $0.message, formattedDate: formatter.localizedString(for: $0.date, relativeTo: Date()))})
	}
}

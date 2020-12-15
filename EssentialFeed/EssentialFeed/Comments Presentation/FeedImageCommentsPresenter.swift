//
//  FeedImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentsLoadingView {
	func display(_ viewModel: FeedImageCommentLoadingViewModel)
}

public protocol FeedImageCommentsErrorView {
	func display(_ viewModel: FeedImageCommentErrorViewModel)
}

public protocol FeedImageCommentsView {
	func display(_ viewModel: FeedImageCommentsViewModel)
}

public class FeedImageCommentsPresenter {
	
	private let commentsView: FeedImageCommentsView
	private let loadingView: FeedImageCommentsLoadingView
	private let errorView: FeedImageCommentsErrorView
	
	public static var title: String { NSLocalizedString(
		"FEED_COMMENTS_VIEW_TITLE",
		tableName: "FeedImageComments",
		bundle: Bundle(for: FeedImageCommentsPresenter.self),
		comment: "Title for the image comments view"
	) }
	
	private static var errorMessage: String { NSLocalizedString(
		"FEED_COMMENTS_VIEW_ERROR_MESSAGE",
		tableName: "FeedImageComments",
		bundle: Bundle(for: FeedImageCommentsPresenter.self),
		comment: "Title for the image comments view"
	) }
	
	public init(commentsView: FeedImageCommentsView,
				loadingView: FeedImageCommentsLoadingView,
				errorView: FeedImageCommentsErrorView) {
		self.commentsView = commentsView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public func didStartLoadingComments() {
		errorView.display(.noError)
		loadingView.display(FeedImageCommentLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingComments(with comments: [ImageComment]) {
		commentsView.display(FeedImageCommentsViewModel(comments: comments.toModels()))
		loadingView.display(FeedImageCommentLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		errorView.display(.error(message: FeedImageCommentsPresenter.errorMessage))
		loadingView.display(FeedImageCommentLoadingViewModel(isLoading: false))
	}
	
}

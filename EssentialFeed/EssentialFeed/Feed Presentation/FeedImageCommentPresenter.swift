//
//  FeedImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Danil Vassyakin on 3/2/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentView {
	func display(_ viewModel: FeedImageCommentViewModel)
}

public protocol FeedImageCommentLoadingView {
	func display(_ viewModel: FeedImageCommentLoadingViewModel)
}

public protocol FeedImageCommentErrorView {
	func display(_ viewModel: FeedImageCommentErrorViewModel)
}

public final class FeedImageCommentPresenter {
	private let commentsView: FeedImageCommentView
	private let errorView: FeedImageCommentErrorView
	private let loadingView: FeedImageCommentLoadingView
	
	public init(commentsView: FeedImageCommentView, errorView: FeedImageCommentErrorView, loadingView: FeedImageCommentLoadingView) {
		self.commentsView = commentsView
		self.errorView = errorView
		self.loadingView = loadingView
	}
	
	public static var title: String {
		NSLocalizedString(
			"FEED_COMMENT_TITLE",
			tableName: "Comments",
			bundle: Bundle(for: FeedImageCommentPresenter.self),
			comment: "Title for comments screen")
	}
	
	private var commentsLoadError: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_ERROR_MESSAGE",
			 tableName: "Comments",
			 bundle: Bundle(for: FeedImageCommentPresenter.self),
			 comment: "Error message displayed when we can't load the image comments from the server")
	}
	
	public func didStartLoadingComments() {
		errorView.display(.noError)
		loadingView.display(.init(isLoading: true))
	}
	
	public func didFinishLoadingComments(with comments: [FeedComment]) {
		commentsView.display(.init(comments: comments))
		loadingView.display(.init(isLoading: false))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		loadingView.display(.init(isLoading: false))
		errorView.display(.error(message: commentsLoadError))
	}
	
}


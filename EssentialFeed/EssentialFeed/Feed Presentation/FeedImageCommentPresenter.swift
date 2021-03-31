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
	private let dateFormatter: RelativeDateTimeFormatter
	private let currentDateProvider: () -> Date
	
	public init(commentsView: FeedImageCommentView, errorView: FeedImageCommentErrorView, loadingView: FeedImageCommentLoadingView, dateFormatter: RelativeDateTimeFormatter, currentDateProvider: @escaping () -> Date) {
		self.commentsView = commentsView
		self.errorView = errorView
		self.loadingView = loadingView
		self.dateFormatter = dateFormatter
		self.currentDateProvider = currentDateProvider
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
		loadingView.display(.loading)
	}
	
	public func didFinishLoadingComments(with comments: [FeedComment]) {
		commentsView.display(.init(comments: presentableComments(from: comments)))
		loadingView.display(.notLoading)
	}
	
	public func didFinishLoadingComments(with error: Error) {
		loadingView.display(.notLoading)
		errorView.display(.error(message: commentsLoadError))
	}
	
	private func presentableComments(from comments: [FeedComment]) -> [PresentationImageComment] {
		comments.map { PresentationImageComment(
			message: $0.message,
			createdAt: format($0.createdAt),
			author: $0.author.username)
		}
	}
	
	private func format(_ date: Date) -> String {
		dateFormatter.localizedString(for: date, relativeTo: currentDateProvider())
	}
	
}

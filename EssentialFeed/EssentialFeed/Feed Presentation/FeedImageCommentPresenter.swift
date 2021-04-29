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
	private let locale: Locale
	private let currentDateProvider: () -> Date
	
	public init(commentsView: FeedImageCommentView, errorView: FeedImageCommentErrorView, loadingView: FeedImageCommentLoadingView, locale: Locale, currentDateProvider: @escaping () -> Date) {
		self.commentsView = commentsView
		self.errorView = errorView
		self.loadingView = loadingView
		self.locale = locale
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
		commentsView.display(.init(comments: FeedImageCommentPresenter.presentableComments(from: comments, date: currentDateProvider, locale: locale)))
		loadingView.display(.notLoading)
	}
	
	public func didFinishLoadingComments(with error: Error) {
		loadingView.display(.notLoading)
		errorView.display(.error(message: commentsLoadError))
	}
	
	public static func presentableComments(from comments: [FeedComment], date: () -> Date, locale: Locale) -> [PresentationImageComment] {
		comments.map { PresentationImageComment(
			message: $0.message,
			createdAt: format(date: $0.createdAt, relativeTo: date(), locale: locale),
			author: $0.author.username)
		}
	}
	
	private static func format(date: Date, relativeTo relativeToDate: Date, locale: Locale) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.locale = locale
		return formatter.localizedString(for: date, relativeTo: relativeToDate)
	}
	
}

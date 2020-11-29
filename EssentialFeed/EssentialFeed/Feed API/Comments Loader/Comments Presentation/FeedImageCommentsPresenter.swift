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
	private let currentDate: Date
	
	public static var title: String { NSLocalizedString(
		"FEED_COMMENTS_VIEW_TITLE",
		tableName: "FeedImageComments",
		bundle: Bundle(for: FeedImageCommentsPresenter.self),
		comment: "Title for the image comments view"
	) }
	
	public static var errorMessage: String { NSLocalizedString(
		"FEED_COMMENTS_VIEW_ERROR_MESSAGE",
		tableName: "FeedImageComments",
		bundle: Bundle(for: FeedImageCommentsPresenter.self),
		comment: "Title for the image comments view"
	) }
	
	public init(commentsView: FeedImageCommentsView,
				loadingView: FeedImageCommentsLoadingView,
				errorView: FeedImageCommentsErrorView,
				currentDate: Date) {
		self.commentsView = commentsView
		self.loadingView = loadingView
		self.errorView = errorView
		self.currentDate = currentDate
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

extension Date {
	
	func timeAgoDisplay() -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		return formatter.localizedString(for: self, relativeTo: Date())
	}
	
}

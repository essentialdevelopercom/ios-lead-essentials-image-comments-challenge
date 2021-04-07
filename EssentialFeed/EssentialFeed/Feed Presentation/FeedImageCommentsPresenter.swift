//
//  FeedImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Ivan Ornes on 10/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentsView {
	func display(_ viewModel: FeedImageCommentsViewModel)
}

public final class FeedImageCommentsPresenter {
	private let feedImageCommentsView: FeedImageCommentsView
	private let loadingView: FeedLoadingView
	private let errorView: FeedErrorView
	private let formatter: RelativeDateTimeFormatter
	private let relativeToDate: Date
	
	private var feedImageCommentsLoadError: String {
		return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
			 tableName: "Feed",
			 bundle: Bundle(for: FeedPresenter.self),
			 comment: "Error message displayed when we can't load the image feed comments from the server")
	}
	
	public init(feedImageCommentsView: FeedImageCommentsView, loadingView: FeedLoadingView, errorView: FeedErrorView, formatter: RelativeDateTimeFormatter, relativeToDate: Date) {
		self.feedImageCommentsView = feedImageCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
		self.formatter = formatter
		self.relativeToDate = relativeToDate
	}
	
	public static var title: String {
		return NSLocalizedString("FEED_COMMENTS_VIEW_TITLE",
			 tableName: "Feed",
			 bundle: Bundle(for: FeedImageCommentsPresenter.self),
			 comment: "Title for the comments view")
	}
	
	public func didStartLoadingComments() {
		errorView.display(.noError)
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingComments(with comments: [FeedImageComment]) {
		let commentViewModels = comments.map { model -> FeedImageCommentViewModel in
			let date = formatter.localizedString(for: model.createdAt, relativeTo: relativeToDate)
			return FeedImageCommentViewModel(message: model.message,
											 creationDate: date,
											 author: model.author.username)
		}
		feedImageCommentsView.display(FeedImageCommentsViewModel(comments: commentViewModels))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		errorView.display(.error(message: feedImageCommentsLoadError))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
}

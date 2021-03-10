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
	
	public init(feedImageCommentsView: FeedImageCommentsView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
		self.feedImageCommentsView = feedImageCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
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
		feedImageCommentsView.display(FeedImageCommentsViewModel(comments: comments))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
}

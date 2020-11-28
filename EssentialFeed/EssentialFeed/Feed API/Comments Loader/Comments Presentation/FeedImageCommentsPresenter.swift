//
//  FeedImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Maxim Soldatov on 11/28/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentsLoadingView {
	func display(isLoading: Bool)
}

public protocol FeedImageCommentsErrorView {
	func display(errorMessage: String?)
}

public protocol FeedImageCommentsView {
	func display(comments: [ImageComment])
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
	
	public init(commentsView: FeedImageCommentsView, loadingView: FeedImageCommentsLoadingView, errorView: FeedImageCommentsErrorView) {
		self.commentsView = commentsView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public func didStartLoadingFeed() {
		errorView.display(errorMessage: nil)
		loadingView.display(isLoading: true)
	}
	
	public func didFinishLoadingFeed(with comments: [ImageComment]) {
		commentsView.display(comments: comments)
		loadingView.display(isLoading: false)
	}
	
}

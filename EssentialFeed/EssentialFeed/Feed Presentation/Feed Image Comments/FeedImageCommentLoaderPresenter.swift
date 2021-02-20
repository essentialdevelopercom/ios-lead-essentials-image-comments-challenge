//
//  FeedImageCommentLoaderPresenter.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 13/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageCommentView {
	func display(_ viewModel: FeedCommentViewModel)
}

public struct FeedCommentViewModel {
	public let comments: [CommentItemViewModel]
}

public struct CommentItemViewModel: Hashable {
	public let message: String
	public let authorName: String
	public let createdAt: String
}

public final class FeedImageCommentLoaderPresenter {
	private let feedCommentView: FeedImageCommentView
	private let loadingView: FeedLoadingView
	private let errorView: FeedErrorView
	
	private var feedLoadError: String {
		return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
			 tableName: "Feed",
			 bundle: Bundle(for: FeedPresenter.self),
			 comment: "Error message displayed when we can't load the image feed from the server")
	}
	
	public init(feedCommentView: FeedImageCommentView, 
				loadingView: FeedLoadingView,
				errorView: FeedErrorView) {
		self.feedCommentView = feedCommentView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public static var title: String {
		return NSLocalizedString("FEED_COMMENT_VIEW_TITLE",
			 tableName: "Feed",
			 bundle: Bundle(for: FeedImageCommentLoaderPresenter.self),
			 comment: "Title for the feed comment view")
	}
	
	public func didStartLoadingFeedComments() {
		errorView.display(.noError)
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingFeed(with comments: [FeedImageComment]) {
		feedCommentView.display(FeedCommentViewModel(comments: map(comments)))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingFeedComments(with error: Error) {
		errorView.display(.error(message: feedLoadError))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	private func map(_ comments: [FeedImageComment]) -> [CommentItemViewModel] {
		comments.map {
			CommentItemViewModel(message: $0.message, 
										  authorName: $0.author, 
										  createdAt: FeedCommentDatePolicy.getRelativeDate(for: $0.creationDate))
		}
	}
} 

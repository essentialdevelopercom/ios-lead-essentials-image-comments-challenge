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

public final class FeedImageCommentLoaderPresenter {
	private let feedCommentView: FeedImageCommentView
	private let loadingView: FeedLoadingView
	
	public init(feedCommentView: FeedImageCommentView, loadingView: FeedLoadingView) {
		self.feedCommentView = feedCommentView
		self.loadingView = loadingView
	}
	
	public func didStartLoadingFeed() {
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingFeed(with comments: [FeedImageComment]) {
		feedCommentView.display(FeedCommentViewModel(comments: comments))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingFeed(with error: Error) {
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
} 

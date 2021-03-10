//
//  FeedImageCommentsPresenter.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed

struct FeedImageCommentLoadingViewModel {
	let isLoading: Bool
}

protocol FeedImageCommentLoadingView {
	func display(_ viewModel: FeedImageCommentLoadingViewModel)
}

struct FeedImageCommentViewModel {
	let comments: [FeedImageComment]
}

protocol FeedImageCommentView {
	func display(_ viewModel: FeedImageCommentViewModel)
}

final class FeedImageCommentsPresenter {
	private let commentsLoader: FeedImageCommentsLoader
	
	public init(commentsLoader: FeedImageCommentsLoader) {
		self.commentsLoader = commentsLoader
	}
	
	var commentsView: FeedImageCommentView?
	var loadingView: FeedImageCommentLoadingView?
	
	func loadComments() {
		loadingView?.display(FeedImageCommentLoadingViewModel(isLoading: true))
		commentsLoader.load { [weak self] result in
			if let comments = try? result.get() {
				self?.commentsView?.display(FeedImageCommentViewModel(comments: comments))
			}
			self?.loadingView?.display(FeedImageCommentLoadingViewModel(isLoading: false))
		}
	}
}

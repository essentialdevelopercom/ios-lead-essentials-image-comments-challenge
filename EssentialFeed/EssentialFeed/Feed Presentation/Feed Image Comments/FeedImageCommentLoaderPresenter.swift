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
	public let comments: [FeedImageComment]
}

public final class FeedImageCommentCellViewModel {
	private let model: FeedImageComment
	
	public init(model: FeedImageComment) {
		self.model = model
	}
	
	public var message: String? {
		return model.message
	}
	
	public var authorName: String?  {
		return model.author
	}
}

public final class FeedImageCommentLoaderPresenter {	
	private let feedCommentLoader: FeedImageCommentLoader
	private let url: URL
	
	public init(feedCommentLoader: FeedImageCommentLoader, url: URL) {
		self.feedCommentLoader = feedCommentLoader
		self.url = url
	}

	public var feedCommentView: FeedImageCommentView?
	public var loadingView: FeedLoadingView?

	public func loadComments() {
		loadingView?.display(FeedLoadingViewModel(isLoading: true))
		_ = feedCommentLoader.loadImageCommentData(from: url) { [weak self] result in
			if let comments = try? result.get() {
				self?.feedCommentView?.display(FeedCommentViewModel(comments: comments))
			}
			self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
		}
	}
} 

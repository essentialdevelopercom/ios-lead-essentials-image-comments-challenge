//
//  CommentsPresenter.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 11.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol CommentLoadingView {
	func display(_ viewModel: CommentLoadingViewModel)
}

public protocol CommentErrorView {
	func display(_ viewModel: CommentErrorViewModel)
}

public protocol CommentView {
	func display(_ viewModel: CommentViewModel)
}

public final class CommentsPresenter {
	private let errorView: CommentErrorView
	private let loadingView: CommentLoadingView
	private let commentsView: CommentView
	
	public static var title: String {
		return NSLocalizedString("COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: CommentsPresenter.self),
			comment: "Title for the comments view")
	}
	
	private var commentsLoadError: String {
		return NSLocalizedString("COMMENTS_VIEW_CONNECTION_ERROR",
			 tableName: "ImageComments",
			 bundle: Bundle(for: CommentsPresenter.self),
			 comment: "Error message displayed when we can't load the comments from the server")
	}
	
	public init(errorView: CommentErrorView, loadingView: CommentLoadingView, commentsView: CommentView) {
		self.errorView = errorView
		self.loadingView = loadingView
		self.commentsView = commentsView
	}
	
	public func didStartLoadingComments() {
		errorView.display(CommentErrorViewModel(message: .none))
		loadingView.display(CommentLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingComments(comments: [Comment]) {
		commentsView.display(CommentViewModel(comments: comments))
		loadingView.display(CommentLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		errorView.display(CommentErrorViewModel(message: commentsLoadError))
		loadingView.display(CommentLoadingViewModel(isLoading: false))
	}
}

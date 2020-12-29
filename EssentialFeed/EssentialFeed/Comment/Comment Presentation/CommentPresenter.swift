//
//  CommentPresenter.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
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

public class CommentPresenter {
	private let loadingView: CommentLoadingView
	private let errorView: CommentErrorView
	private let commentView: CommentView
	private var commentLoadError: String {
		return NSLocalizedString("COMMENT_VIEW_CONNECTION_ERROR",
								 tableName: "Comment",
								 bundle: Bundle(for: CommentPresenter.self),
								 comment: "Title for the comment view")
	}
	
	public init(loadingView: CommentLoadingView, errorView: CommentErrorView, commentView: CommentView) {
		self.loadingView = loadingView
		self.errorView = errorView
		self.commentView = commentView
	}
	
	public static var title: String {
		return NSLocalizedString("COMMENT_VIEW_TITLE",
								 tableName: "Comment",
								 bundle: Bundle(for: CommentPresenter.self),
								 comment: "Title for the comment view")
	}
	
	public func didStartLoadingComment() {
		loadingView.display(CommentLoadingViewModel(isLoading: true))
		errorView.display(CommentErrorViewModel.noError)
	}
	
	public func didFinishLoadingComment(with error: Error) {
		loadingView.display(CommentLoadingViewModel(isLoading: false))
		errorView.display(CommentErrorViewModel.error(message: commentLoadError))
	}
	
	public func didFinishLoadingComment(with comments: [Comment]) {
		loadingView.display(CommentLoadingViewModel(isLoading: false))
		commentView.display(CommentViewModel(comments: comments))
	}
}

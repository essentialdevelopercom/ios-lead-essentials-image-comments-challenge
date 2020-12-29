//
//  CommentPresenter.swift
//  EssentialFeed
//
//  Created by Khoi Nguyen on 28/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public protocol CommentLoadingView {
	func display(isLoading: Bool)
}

public protocol CommentErrorView {
	func display(errorMessage: String?)
}

public protocol CommentView {
	func display(_ comments: [Comment])
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
		loadingView.display(isLoading: true)
		errorView.display(errorMessage: nil)
	}
	
	public func didFinishLoadingComment(with error: Error) {
		loadingView.display(isLoading: false)
		errorView.display(errorMessage: commentLoadError)
	}
	
	public func didFinishLoadingComment(with comments: [Comment]) {
		loadingView.display(isLoading: false)
		commentView.display(comments)
	}
}

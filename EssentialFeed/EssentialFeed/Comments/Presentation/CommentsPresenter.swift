//
//  CommentsPresenter.swift
//  EssentialFeed
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation


public final class CommentsPresenter {
	private let commentView: CommentView
	private let errorView: CommentErrorView
	private let loadingView: CommentLoadingView
	
	public init(commentView: CommentView, loadingView: CommentLoadingView, errorView: CommentErrorView) {
		self.commentView = commentView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	public static var title: String {
		return NSLocalizedString("COMMENTS_VIEW_TITLE",
								 tableName: "Comments",
								 bundle: Bundle(for: CommentsPresenter.self),
								 comment: "Title for Comment View")
	}
	
	public func didStartLoadingFeed() {
		errorView.display(.noError)
		loadingView.display(CommentLoadingViewModel(isLoading: true))
	}
}

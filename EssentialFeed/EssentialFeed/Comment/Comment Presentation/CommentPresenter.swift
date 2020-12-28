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

public class CommentPresenter {
	private let loadingView: CommentLoadingView
	private let errorView: CommentErrorView
	
	public init(loadingView: CommentLoadingView, errorView: CommentErrorView) {
		self.loadingView = loadingView
		self.errorView = errorView
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
}

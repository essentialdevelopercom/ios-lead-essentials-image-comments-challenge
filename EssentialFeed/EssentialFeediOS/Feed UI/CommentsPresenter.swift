//
//  CommentsPresenter.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

struct CommentLoadingViewModel {
	let isLoading: Bool
}

protocol CommentLoadingView {
	func display(_ viewModel: CommentLoadingViewModel)
}

struct CommentViewModel {
	let comments: [Comment]
}

protocol CommentView {
	func display(_ viewModel: CommentViewModel)
}

final class CommentsPresenter {
	private let commentsView: CommentView
	private let loadingView: CommentLoadingView
	
	init(commentsView: CommentView, loadingView: CommentLoadingView) {
		self.commentsView = commentsView
		self.loadingView = loadingView
	}
	
	static var title: String {
		return NSLocalizedString("COMMENTS_VIEW_TITLE",
			tableName: "Comments",
			bundle: Bundle(for: CommentsPresenter.self),
			comment: "Title for the comments view")
	}
	
	func didStartLoadingComments() {
		loadingView.display(CommentLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingComments(comments: [Comment]) {
		commentsView.display(CommentViewModel(comments: comments))
		loadingView.display(CommentLoadingViewModel(isLoading: false))
	}
	
	func didFinishLoadingComments(with error: Error) {
		loadingView.display(CommentLoadingViewModel(isLoading: false))
	}
}

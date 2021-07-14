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
	func display(_ viewModel: CommentListViewModel)
}

public final class CommentsPresenter {
	private let errorView: CommentErrorView
	private let loadingView: CommentLoadingView
	private let commentsView: CommentView
	
	public var title: String {
		return NSLocalizedString("COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: CommentsPresenter.self),
			comment: "Title for the comments view")
	}
	
	public static var commentsLoadError: String {
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
		let model = CommentsPresenter.map(comments)
		commentsView.display(model)
		loadingView.display(CommentLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		errorView.display(CommentErrorViewModel(message: CommentsPresenter.commentsLoadError))
		loadingView.display(CommentLoadingViewModel(isLoading: false))
	}
	
	public static func map(
		_ comments: [Comment],
		currentDate: Date = Date(),
		calendar: Calendar = .current,
		locale: Locale = .current
	) -> CommentListViewModel {
		let formatter = RelativeDateTimeFormatter()
		formatter.calendar = calendar
		formatter.locale = locale
		let models = comments.map { comment -> CommentViewModel in
			let date = formatter.localizedString(for: comment.createdAt, relativeTo: currentDate)
			return CommentViewModel(message: comment.message, author: comment.author, date: date)
		}
		return CommentListViewModel(comments: models)
	}
}

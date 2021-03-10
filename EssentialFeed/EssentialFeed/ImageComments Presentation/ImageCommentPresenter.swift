//
//  ImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Eric Garlock on 3/10/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class ImageCommentPresenter {
	
	public static var title: String {
		return NSLocalizedString("COMMENT_VIEW_TITLE", tableName: "ImageComments", bundle: Bundle(for: ImageCommentPresenter.self), comment: "Title for the comments view")
	}
	
	public static var errorMessage: String {
		return NSLocalizedString("COMMENT_VIEW_ERROR_MESSAGE", tableName: "ImageComments", bundle: Bundle(for: ImageCommentPresenter.self), comment: "Error message for the comments view")
	}
	
	private let commentView: ImageCommentView
	private let loadingView: ImageCommentLoadingView
	private let errorView: ImageCommentErrorView
	
	private let currentDate: () -> Date
	private let locale: Locale
	private let calendar = Calendar(identifier: .gregorian)
	
	public init(commentView: ImageCommentView, loadingView: ImageCommentLoadingView, errorView: ImageCommentErrorView, currentDate: @escaping () -> Date = Date.init, locale: Locale = .current) {
		self.commentView = commentView
		self.loadingView = loadingView
		self.errorView = errorView
		self.currentDate = currentDate
		self.locale = locale
	}
	
	public func didStartLoadingComments() {
		loadingView.display(.loading)
		errorView.display(.clear)
	}
	
	public func didFinishLoadingComments(with comments: [ImageComment]) {
		loadingView.display(.finished)
		commentView.display(ImageCommentsViewModel(comments: comments.map { comment in
			ImageCommentViewModel(message: comment.message, created: formatted(since: comment.createdAt), username: comment.author.username)
		}))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		loadingView.display(.finished)
		errorView.display(ImageCommentErrorViewModel(message: ImageCommentPresenter.errorMessage))
	}
	
	private func formatted(since date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		formatter.locale = locale
		formatter.calendar = calendar
		return formatter.localizedString(for: date, relativeTo: currentDate())
	}
	
}

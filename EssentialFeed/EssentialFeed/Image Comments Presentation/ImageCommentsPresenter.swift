//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 15/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsLoadingView {
	func display(isLoading: Bool)
}

public protocol ImageCommentsErrorView {
	func display(errorMessage: String?)
}

public protocol ImageCommentsView {
	func display(comments: [ImageComment])
}

public final class ImageCommentsPresenter {

	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: Self.self),
			comment: "Title for the image comments view"
		)
	}

	private var errorMessage: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_CONNECTION_ERROR",
			tableName: "ImageComments",
			bundle: Bundle(
				for: ImageCommentsPresenter.self
			),
			comment: "Error message for a loading comments error"
		)
	}

	private let commentsView: ImageCommentsView
	private let loadingView: ImageCommentsLoadingView
	private let errorView: ImageCommentsErrorView

	public init(
		commentsView: ImageCommentsView,
		loadingView: ImageCommentsLoadingView,
		errorView: ImageCommentsErrorView
	) {
		self.commentsView = commentsView
		self.loadingView = loadingView
		self.errorView = errorView
	}

	public func didStartLoading() {
		errorView.display(errorMessage: nil)
		loadingView.display(isLoading: true)
	}

	public func didFinishLoading(
		with comments: [ImageComment]
	) {
		commentsView.display(comments: comments)
		loadingView.display(isLoading: false)
	}

	public func didFinishLoading(with error: Error) {
		errorView.display(errorMessage: errorMessage)
		loadingView.display(isLoading: false)
	}
}

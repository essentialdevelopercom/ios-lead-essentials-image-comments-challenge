//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 15/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

public protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

public protocol ImageCommentsView {
	func display(_ viewModel: ImageCommentsViewModel)
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

	public static func map(
		_ comments: [ImageComment],
		currentDate: Date = Date(),
		calendar: Calendar = .current,
		locale: Locale = .current
	) -> ImageCommentsViewModel {
		let formatter = RelativeDateTimeFormatter()
		formatter.calendar = calendar
		formatter.locale = locale
		return ImageCommentsViewModel(comments: comments.map {
			ImageCommentViewModel(
				message: $0.message,
				date: formatter.localizedString(
					for: $0.createdAt,
					relativeTo: currentDate
				),
				username: $0.username
			)
		})
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
		errorView.display(.noError)
		loadingView.display(.loading)
	}

	public func didFinishLoading(
		with comments: [ImageComment]
	) {
		commentsView.display(Self.map(comments))
		loadingView.display(.notLoading)
	}

	public func didFinishLoading(with error: Error) {
		errorView.display(.error(message: errorMessage))
		loadingView.display(.notLoading)
	}
}

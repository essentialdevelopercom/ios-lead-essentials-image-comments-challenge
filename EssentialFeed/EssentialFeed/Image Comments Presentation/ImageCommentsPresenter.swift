//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsView {
	func display(_ viewModel: ImageCommentsViewModel)
}

public protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

public protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

public final class ImageCommentsPresenter {
	private let imageCommentsView: ImageCommentsView
	private let loadingView: ImageCommentsLoadingView
	private let errorView: ImageCommentsErrorView
	private let currentDate: () -> Date
	
	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the image comments view")
	}
	
	private var errorMessage: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_CONNECTION_ERROR",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Error message when loading comments fails"
		)
	}
	
	public init(
		imageCommentsView: ImageCommentsView,
		loadingView: ImageCommentsLoadingView,
		errorView: ImageCommentsErrorView,
		currentDate: @escaping () -> Date = Date.init
	) {
		self.imageCommentsView = imageCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
		self.currentDate = currentDate
	}
	
	public func didStartLoadingComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(.noError)
	}
	
	public func didFinishLoading(with comments: [ImageComment]) {
		let presentableComments = ImageCommentsPresenter.map(comments, currentDate: currentDate)
		imageCommentsView.display(ImageCommentsViewModel(comments: presentableComments))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoading(with error: Error) {
		errorView.display(.error(message: errorMessage))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	public static func map(
		_ comments: [ImageComment],
		currentDate: () -> Date = Date.init,
		locale: Locale = .current,
		calendar: Calendar = .current
	) -> [PresentableImageComment] {
		let formatter = RelativeDateTimeFormatter()
		formatter.locale = locale
		formatter.calendar = calendar
		
		return comments.map { comment in
			PresentableImageComment(
				createdAt: formatter.localizedString(for: comment.createdAt, relativeTo: currentDate()),
				message: comment.message,
				author: comment.author.username)
		}
	}
}

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
	private let currentDate: Date
	
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
		currentDate: Date = Date()
	) {
		self.imageCommentsView = imageCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
		self.currentDate = currentDate
	}
	
	public func didStartLoadingComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentsErrorViewModel(errorMessage: nil))
	}
	
	public func didFinishLoading(with comments: [ImageComment]) {
		let presentableComments = comments.map { comment in
			PresentableImageComment(
				createdAt: relativeDate(from: comment.createdAt),
				message: comment.message,
				author: comment.author.username)
		}
		imageCommentsView.display(ImageCommentsViewModel(comments: presentableComments))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoading(with error: Error) {
		errorView.display(ImageCommentsErrorViewModel(errorMessage: errorMessage))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	private static var relativeDateFormatter: RelativeDateTimeFormatter {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		formatter.locale = .current
		formatter.calendar = Calendar(identifier: .gregorian)
		return formatter
	}
	
	private func relativeDate(from date: Date) -> String {
		return ImageCommentsPresenter.relativeDateFormatter.localizedString(for: date, relativeTo: currentDate)
	}
}

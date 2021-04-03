//
//  ImageCommentsListPresenter.swift
//  EssentialFeed
//
//  Created by Ángel Vázquez on 26/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

// MARK: - ViewModels

public struct ImageCommentsLoadingViewModel {
	public let isLoading: Bool
}

public struct ImageCommentsListViewModel {
	public let comments: [ImageComment]
}

public struct ImageCommentsErrorViewModel {
	public let message: String?
}

public struct ImageCommentViewModel {
	public let author: String
	public let message: String
	public let creationDate: String
}

// MARK: - View Protocols

public protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

public protocol ImageCommentsListView {
	func display(_ viewModel: ImageCommentsListViewModel)
}

public protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

// MARK: - ImageCommentsListPresenter

public final class ImageCommentsListPresenter {
	
	private let currentDate: () -> Date
	private let loadingView: ImageCommentsLoadingView
	private let commentsView: ImageCommentsListView
	private let errorView: ImageCommentsErrorView
	private let locale: Locale
	
	public init(currentDate: @escaping () -> Date, loadingView: ImageCommentsLoadingView, commentsView: ImageCommentsListView, errorView: ImageCommentsErrorView, locale: Locale = Locale.current) {
		self.currentDate = currentDate
		self.loadingView = loadingView
		self.commentsView = commentsView
		self.errorView = errorView
		self.locale = locale
	}
	
	public func didStartLoadingComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentsErrorViewModel(message: nil))
	}
	
	public func didFinishLoadingComments(with comments: [ImageComment]) {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
		commentsView.display(ImageCommentsListViewModel(comments: comments))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
		errorView.display(ImageCommentsErrorViewModel(message: Localized.ImageComments.errorMessage))
	}
	
	public func viewModel(for comment: ImageComment) -> ImageCommentViewModel {
		ImageCommentViewModel(
			author: comment.author,
			message: comment.message,
			creationDate: formatRelativeDate(for: comment.creationDate)
		)
	}
	
	private func formatRelativeDate(for date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.locale = locale
		return formatter.localizedString(for: date, relativeTo: currentDate())
	}
}

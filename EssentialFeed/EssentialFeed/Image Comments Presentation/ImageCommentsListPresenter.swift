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
	public let comments: [ImageCommentViewModel]
}

public struct ImageCommentsErrorViewModel {
	public let message: String?
}

public struct ImageCommentViewModel: Hashable {
	public let author: String
	public let message: String
	public let creationDate: String
	
	public init(author: String, message: String, creationDate: String) {
		self.author = author
		self.message = message
		self.creationDate = creationDate
	}
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
	private let loadingView: ImageCommentsLoadingView
	private let commentsView: ImageCommentsListView
	private let errorView: ImageCommentsErrorView
	
	private let currentDate: () -> Date
	private let locale: Locale
	
	public init(loadingView: ImageCommentsLoadingView, commentsView: ImageCommentsListView, errorView: ImageCommentsErrorView, currentDate: @escaping () -> Date, locale: Locale = Locale.current) {
		self.loadingView = loadingView
		self.commentsView = commentsView
		self.errorView = errorView
		self.currentDate = currentDate
		self.locale = locale
	}
	
	public func didStartLoadingComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentsErrorViewModel(message: nil))
	}
	
	public func didFinishLoadingComments(with comments: [ImageComment]) {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
		commentsView.display(
			ImageCommentsListViewModel(
				comments: ImageCommentViewModelMapper.map(comments, currentDate: currentDate, locale: locale)
			)
		)
	}
	
	public func didFinishLoadingComments(with error: Error) {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
		errorView.display(ImageCommentsErrorViewModel(message: Localized.ImageComments.errorMessage))
	}
}

public final class ImageCommentViewModelMapper {
	public static func map(_ comments: [ImageComment], currentDate: () -> Date, locale: Locale) -> [ImageCommentViewModel] {
		comments.map { comment in
			ImageCommentViewModel(
				author: comment.author,
				message: comment.message,
				creationDate: comment.creationDate.dateString(relativeTo: currentDate(), locale: locale)
			)
		}
	}
}

private extension Date {
	func dateString(relativeTo date: Date, locale: Locale) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.locale = locale
		return formatter.localizedString(for: self, relativeTo: date)
	}
}

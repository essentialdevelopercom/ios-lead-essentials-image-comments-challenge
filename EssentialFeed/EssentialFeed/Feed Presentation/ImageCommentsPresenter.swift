//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Adrian Szymanowski on 08/03/2021.
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

public class ImageCommentsPresenter {
	private let commentsView: ImageCommentsView
	private let loadingView: ImageCommentsLoadingView
	private let errorView: ImageCommentsErrorView
	private let timeFormatConfiguration: TimeFormatConfiguration
	
	public init(commentsView: ImageCommentsView, loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView, timeFormatConfiguration: TimeFormatConfiguration) {
		self.commentsView = commentsView
		self.loadingView = loadingView
		self.errorView = errorView
		self.timeFormatConfiguration = timeFormatConfiguration
	}
	
	public func didStartLoadingComments() {
		errorView.display(ImageCommentsErrorViewModel(message: .none))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingComments(with comments: [ImageComment]) {
		commentsView.display(ImageCommentsViewModel(
			comments: ImageCommentsViewModelMapper.map(
				comments,
				timeFormatConfiguration: timeFormatConfiguration)
		))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingComments(with error: Error) {
		errorView.display(ImageCommentsErrorViewModel(message: imageCommentsLoadError))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
	
	private var imageCommentsLoadError: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_CONNECTION_ERROR",
			tableName: ImageCommentsPresenter.tableName,
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Error message displayed when we can't load the image comments from the server")
	}
	
	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_TITLE",
			tableName: tableName,
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the image comments view")
	}
	
	public static var tableName: String { "ImageComments" }
}

//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Alok Subedi on 03/02/2021.
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
	private let loadingView: ImageCommentsLoadingView
	private let errorView: ImageCommentsErrorView
	private let imageCommentsView: ImageCommentsView
	
	private let dateFormatter = RelativeDateTimeFormatter()
	
	public init(imageCommentsView: ImageCommentsView,
				loadingView: ImageCommentsLoadingView,
				errorView: ImageCommentsErrorView,
				locale: Locale = Locale.current) {
		self.imageCommentsView = imageCommentsView
		self.loadingView = loadingView
		self.errorView = errorView
		self.dateFormatter.locale = locale
	}
	
	public static var title: String {
		return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
								 tableName: "ImageComments",
								 bundle: Bundle(for: FeedPresenter.self),
								 comment: "Title for the image comments view")
	}
	
	private var localizedErrorMessage: String {
		return NSLocalizedString("IMAGE_COMMENTS_VIEW_CONNECTION_ERROR",
								 tableName: "ImageComments",
								 bundle: Bundle(for: FeedPresenter.self),
								 comment: "Error message displayed when we can't load the image comments from the server")
	}
	
	public func didStartLoadingImageComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentsErrorViewModel(message: nil))
	}
	
	public func didFinishLoadingImageComments(with comments: [ImageComment]) {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
		imageCommentsView.display(ImageCommentsViewModel(comments: presentableComment(from: comments)))
	}
	
	public func didFinishLoadingImageComments(with error: Error) {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
		errorView.display(ImageCommentsErrorViewModel(message: localizedErrorMessage))
	}
	
	private func presentableComment(from comments: [ImageComment]) -> [PresentableImageComment] {
		return comments.map {
			PresentableImageComment(username: $0.author.username, message: $0.message, date: relativeDateStringFromNow(to: $0.createdDate))
		}
	}
	
	private func relativeDateStringFromNow(to date: Date) -> String {
		return dateFormatter.localizedString(for: date, relativeTo: Date())
	}
}

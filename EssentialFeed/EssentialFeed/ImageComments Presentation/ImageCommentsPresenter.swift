//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 27.03.2021.
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
	public let imageCommentsView: ImageCommentsView
	public let imageCommentsLoadingView: ImageCommentsLoadingView
	public let imageCommentsErrorView: ImageCommentsErrorView

	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the comments view"
		)
	}

	private var imageCommentsLoadError: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_CONNECTION_ERROR",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Error message displayed when we can't load the image comments from the server"
		)
	}

	public init(imageCommentsView: ImageCommentsView, imageCommentsLoadingView: ImageCommentsLoadingView, imageCommentsErrorView: ImageCommentsErrorView) {
		self.imageCommentsView = imageCommentsView
		self.imageCommentsLoadingView = imageCommentsLoadingView
		self.imageCommentsErrorView = imageCommentsErrorView
	}

	public func didStartLoadingImageComments() {
		imageCommentsErrorView.display(.noError)
		imageCommentsLoadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
	}

	public func didFinishLoadingImageComments(with imageComments: [ImageComment]) {
		imageCommentsView.display(ImageCommentsViewModel(imageComments: imageComments))
		imageCommentsLoadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}

	public func didFinishLoadingImageComments(with error: Error) {
		imageCommentsErrorView.display(.error(message: imageCommentsLoadError))
		imageCommentsLoadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}

	public func didFinishLoadingImageComments(with imageComments: [ImageComment]) {
		imageCommentsView.display(ImageCommentsViewModel(imageComments: imageComments))
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
}

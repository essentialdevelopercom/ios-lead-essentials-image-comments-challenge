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

public final class ImageCommentsPresenter {
	public let imageCommentsView: ImageCommentsView
	public let imageCommentsLoadingView: ImageCommentsLoadingView

	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the comments view"
		)
	}

	public init(imageCommentsView: ImageCommentsView, imageCommentsLoadingView: ImageCommentsLoadingView) {
		self.imageCommentsView = imageCommentsView
		self.imageCommentsLoadingView = imageCommentsLoadingView
	}

	public func didStartLoadingImageComments() {
		imageCommentsLoadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
	}

	public func didFinishLoadingImageComments(with imageComments: [ImageComment]) {
		imageCommentsView.display(ImageCommentsViewModel(imageComments: imageComments))
		imageCommentsLoadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}

	public func didFinishLoadingImageComments(with error: Error) {
		imageCommentsLoadingView.display(ImageCommentsLoadingViewModel(isLoading: false))
	}
}

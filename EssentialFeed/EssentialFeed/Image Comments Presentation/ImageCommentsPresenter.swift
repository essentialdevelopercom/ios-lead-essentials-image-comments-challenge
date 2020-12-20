//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Cronay on 20.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public struct ImageCommentsLoadingViewModel {
	public let isLoading: Bool
}

public protocol ImageCommentsLoadingView {
	func display(_ viewModel: ImageCommentsLoadingViewModel)
}

public struct ImageCommentsErrorViewModel {
	public let message: String?
}

public protocol ImageCommentsErrorView {
	func display(_ viewModel: ImageCommentsErrorViewModel)
}

public class ImageCommentsPresenter {

	let loadingView: ImageCommentsLoadingView
	let errorView: ImageCommentsErrorView

	public init(loadingView: ImageCommentsLoadingView, errorView: ImageCommentsErrorView) {
		self.loadingView = loadingView
		self.errorView = errorView
	}

	public static var title: String {
		return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
			 tableName: "ImageComments",
			 bundle: Bundle(for: ImageCommentsPresenter.self),
			 comment: "Title for Image Comments view")
	}

	public func didStartLoadingComments() {
		loadingView.display(ImageCommentsLoadingViewModel(isLoading: true))
		errorView.display(ImageCommentsErrorViewModel(message: nil))
	}
}

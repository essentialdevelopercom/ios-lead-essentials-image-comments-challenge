//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Raphael Silva on 15/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentsLoadingView {
	func display(isLoading: Bool)
}

public protocol ImageCommentsErrorView {
	func display(errorMessage: String?)
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

	private let loadingView: ImageCommentsLoadingView
	private let errorView: ImageCommentsErrorView

	public init(
		loadingView: ImageCommentsLoadingView,
		errorView: ImageCommentsErrorView
	) {
		self.loadingView = loadingView
		self.errorView = errorView
	}

	public func didStartLoading() {
		errorView.display(errorMessage: nil)
		loadingView.display(isLoading: true)
	}
}

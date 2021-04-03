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
	public var imageCommentsView: ImageCommentsView?
	public var imageCommentsLoadingView: ImageCommentsLoadingView?
	private let imageCommentsLoader: ImageCommentsLoader

	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the comments view"
		)
	}

	public init(imageCommentsLoader: ImageCommentsLoader) {
		self.imageCommentsLoader = imageCommentsLoader
	}

	public func loadImageComments() {
		imageCommentsLoadingView?.display(ImageCommentsLoadingViewModel(isLoading: true))
		imageCommentsLoader.load { [weak self] result in
			if let imageComments = try? result.get() {
				self?.imageCommentsView?.display(ImageCommentsViewModel(imageComments: imageComments))
			}
			self?.imageCommentsLoadingView?.display(ImageCommentsLoadingViewModel(isLoading: false))
		}
	}
}

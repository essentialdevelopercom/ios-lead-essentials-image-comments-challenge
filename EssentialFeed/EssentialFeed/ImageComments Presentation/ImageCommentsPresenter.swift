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

public final class ImageCommentsPresenter {
	private let imageCommentsView: ImageCommentsView

	public static var title: String {
		NSLocalizedString(
			"IMAGE_COMMENTS_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: ImageCommentsPresenter.self),
			comment: "Title for the comments view"
		)
	}

	public init(imageCommentsView: ImageCommentsView) {
		self.imageCommentsView = imageCommentsView
	}
}

//
//  ImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public protocol ImageCommentView {
	func display(_ viewModel: ImageCommentViewModel)
}

public final class ImageCommentPresenter {
	public let imageCommentView: ImageCommentView

	private let formattedDate: (Date) -> String?

	public init(imageCommentView: ImageCommentView, formattedDate: @escaping (Date) -> String?) {
		self.imageCommentView = imageCommentView
		self.formattedDate = formattedDate
	}

	public func shouldDisplayImageComment(_ imageComment: ImageComment) {
		imageCommentView.display(
			ImageCommentViewModel(
				message: imageComment.message,
				username: imageComment.username,
				createdAt: formattedDate(imageComment.createdAt)
			)
		)
	}

	public func shouldDisplayNoImageComment() {
		imageCommentView.display(
			ImageCommentViewModel(
				message: nil,
				username: nil,
				createdAt: nil
			)
		)
	}
}

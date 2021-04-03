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

	private lazy var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		df.timeStyle = .medium
		return df
	}()

	public init(imageCommentView: ImageCommentView) {
		self.imageCommentView = imageCommentView
	}

	public func shouldDisplayImageComment(_ imageComment: ImageComment) {
		imageCommentView.display(
			ImageCommentViewModel(
				message: imageComment.message,
				author: imageComment.author.username,
				createdAt: dateFormatter.string(from: imageComment.createdAt)
			)
		)
	}

	public func shouldDisplayNoImageComment() {
		imageCommentView.display(
			ImageCommentViewModel(
				message: nil,
				author: nil,
				createdAt: nil
			)
		)
	}
}

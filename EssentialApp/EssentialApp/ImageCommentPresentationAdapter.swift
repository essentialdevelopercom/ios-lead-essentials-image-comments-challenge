//
//  ImageCommentPresentationAdapter.swift
//  EssentialApp
//
//  Created by Sebastian Vidrea on 09.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS

final class ImageCommentPresentationAdapter: ImageCommentCellControllerDelegate {
	private let imageComment: ImageComment
	var presenter: ImageCommentPresenter?

	init(imageComment: ImageComment) {
		self.imageComment = imageComment
	}

	func didLoadCell() {
		presenter?.shouldDisplayImageComment(imageComment)
	}

	func willReleaseCell() {
		presenter?.shouldDisplayNoImageComment()
	}
}

//
//  ImageCommentCellPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 23/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed

final class ImageCommentCellPresentationAdapter: ImageCommentCellControllerDelegate {
	private let comment: ImageComment
	var presenter: ImageCommentPresenter?
	
	init(comment: ImageComment) {
		self.comment = comment
	}
	
	func didRequestComment() {
		presenter?.didLoadComment(comment)
	}
}

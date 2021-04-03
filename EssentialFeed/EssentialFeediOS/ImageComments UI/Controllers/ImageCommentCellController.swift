//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final class ImageCommentCellController: ImageCommentView {
	private(set) lazy var view = ImageCommentCell()

	func display(_ viewModel: ImageCommentViewModel) {
		view.messageLabel.text = viewModel.message
		view.authorNameLabel.text = viewModel.author
		view.createdAtLabel.text = viewModel.createdAt
	}
}

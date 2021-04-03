//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

final class ImageCommentCellController {
	private(set) lazy var view = binded(ImageCommentCell())

	private let viewModel: ImageCommentViewModel

	init(viewModel: ImageCommentViewModel) {
		self.viewModel = viewModel
	}

	private func binded(_ cell: ImageCommentCell) -> ImageCommentCell {
		cell.messageLabel.text = viewModel.message
		cell.authorNameLabel.text = viewModel.author
		cell.createdAtLabel.text = viewModel.createdAt
		return cell
	}
}

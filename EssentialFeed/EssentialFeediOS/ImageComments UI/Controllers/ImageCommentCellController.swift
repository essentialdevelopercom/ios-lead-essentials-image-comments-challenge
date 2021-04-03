//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

protocol ImageCommentCellControllerDelegate {
	func didLoadCell()
	func willReleaseCell()
}

final class ImageCommentCellController: ImageCommentView {
	private let delegate: ImageCommentCellControllerDelegate
	private var cell: ImageCommentCell?

	init(delegate: ImageCommentCellControllerDelegate) {
		self.delegate = delegate
	}

	func removeCell() {
		delegate.willReleaseCell()
		releaseCellForReuse()
	}

	private func releaseCellForReuse() {
		cell = nil
	}

	func view(in tableView: UITableView) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell") as! ImageCommentCell
		self.cell = cell
		delegate.didLoadCell()
		return cell
	}

	func display(_ viewModel: ImageCommentViewModel) {
		cell?.messageLabel.text = viewModel.message
		cell?.authorNameLabel.text = viewModel.author
		cell?.createdAtLabel.text = viewModel.createdAt
	}
}

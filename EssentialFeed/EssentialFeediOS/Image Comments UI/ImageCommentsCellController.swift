//
//  ImageCommentsCellController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

protocol ImageCommentCellControllerDelegate {
	func didRequestComment()
}

final class ImageCommentsCellController: ImageCommentView {
	private let delegate: ImageCommentCellControllerDelegate
	private lazy var cell = ImageCommentCell()
	
	init(delegate: ImageCommentCellControllerDelegate) {
		self.delegate = delegate
	}
	
	func view() -> UITableViewCell {
		delegate.didRequestComment()
		return cell
	}
	
	func display(_ viewModel: ImageCommentViewModel) {
		cell.authorLabel.text = viewModel.author
		cell.messageLabel.text = viewModel.message
		cell.creationDateLabel.text = viewModel.creationDate
	}
}

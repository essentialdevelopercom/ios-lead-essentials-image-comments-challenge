//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentCellController {
	private var cell: ImageCommentCell?
	private let viewModel: ImageCommentViewModel
	
	public init(viewModel: ImageCommentViewModel) {
		self.viewModel = viewModel
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		display(viewModel)
		return cell!
	}
	
	private func display(_ viewModel: ImageCommentViewModel) {
		cell?.authorLabel.text = viewModel.authorUsername
		cell?.relativeDateLabel.text = viewModel.createdAt
		cell?.messageLabel.text = viewModel.message
	}
}

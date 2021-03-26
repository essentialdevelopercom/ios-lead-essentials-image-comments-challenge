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
	private let viewModel: ImageCommentViewModel
	
	public init(viewModel: ImageCommentViewModel) {
		self.viewModel = viewModel
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		cell.authorLabel.text = viewModel.authorUsername
		cell.relativeDateLabel.text = viewModel.createdAt
		cell.messageLabel.text = viewModel.message
		return cell
	}
}

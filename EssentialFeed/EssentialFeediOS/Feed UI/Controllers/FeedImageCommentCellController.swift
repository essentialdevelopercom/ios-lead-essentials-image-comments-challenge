//
//  FeedImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Ivan Ornes on 15/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public class FeedImageCommentCellController {
	private let viewModel: FeedImageCommentViewModel
	
	public init(viewModel: FeedImageCommentViewModel) {
		self.viewModel = viewModel
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		let cell: FeedImageCommentCell = tableView.dequeueReusableCell()
		cell.messageLabel.text = viewModel.message
		cell.createdAtLabel.text = viewModel.creationDate
		cell.authorLabel.text = viewModel.author
		return cell
	}
}

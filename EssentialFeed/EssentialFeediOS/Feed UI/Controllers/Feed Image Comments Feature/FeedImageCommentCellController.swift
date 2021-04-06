//
//  FeedImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Mario Alberto Barragán Espinosa on 12/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedImageCommentCellController {
	private let model: CommentItemViewModel
	
	public init(model: CommentItemViewModel) {
		self.model = model
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		let cell: FeedImageCommentCell = tableView.dequeueReusableCell()
		cell.messageLabel.text = model.message
		cell.authorNameLabel.text = model.authorName
		cell.createdAtLabel.text = model.createdAt
		return cell
	}
}


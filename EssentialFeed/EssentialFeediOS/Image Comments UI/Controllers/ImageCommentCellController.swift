//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Antonio Mayorga on 4/24/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: CellController {
	private let model: ImageCommentViewModel

	public init(model: ImageCommentViewModel) {
		self.model = model
	}

	public func view(in tableView: UITableView) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		cell.messageLabel.text = model.message
		cell.usernameLabel.text = model.username
		cell.dateLabel.text = model.date
		return cell
	}
}

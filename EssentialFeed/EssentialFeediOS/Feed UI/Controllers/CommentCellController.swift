//
//  CommentCellController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class CommentCellController {
	private let model: CommentViewModel
	
	public init(model: CommentViewModel) {
		self.model = model
	}
	
	func view(for tableView: UITableView) -> UITableViewCell {
		let cell: CommentCell = tableView.dequeueReusableCell()
		cell.authorLabel.text = model.author
		cell.dateLabel.text = model.date
		cell.commentLabel.text = model.message
		return cell
	}
}

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
	private let model: Comment
	
	init(model: Comment) {
		self.model = model
	}
	
	func view(for tableView: UITableView) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
		return binded(cell)
	}
	
	private func binded(_ cell: CommentCell) -> CommentCell {
		cell.authorLabel.text = model.author.username
		cell.dateLabel.text = model.createdAt
		cell.commentLabel.text = model.message
		return cell
	}
}

//
//  FeedImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 09.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedImageCommentCellController {
	private let model: FeedImageComment
	
	init(model: FeedImageComment) {
		self.model = model
	}
	
	func view(for tableView: UITableView) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCommentCell") as! FeedImageCommentCell
		return binded(cell)
	}
	
	private func binded(_ cell: FeedImageCommentCell) -> FeedImageCommentCell {
		cell.authorLabel.text = model.author.username
		cell.dateLabel.text = model.createdAt
		cell.commentLabel.text = model.message
		return cell
	}
}

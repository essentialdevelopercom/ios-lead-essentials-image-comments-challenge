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
	
	public init(model: Comment) {
		self.model = model
	}
	
	func view(for tableView: UITableView) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
		return binded(cell)
	}
	
	private func binded(_ cell: CommentCell) -> CommentCell {
		let formatter = RelativeDateTimeFormatter()
		let relativeDate = formatter.localizedString(for: model.createdAt, relativeTo: Date())

		cell.authorLabel.text = model.author
		cell.dateLabel.text = relativeDate
		cell.commentLabel.text = model.message
		return cell
	}
}

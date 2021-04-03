//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 03.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final class ImageCommentCellController {
	private let model: ImageComment

	private var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		df.timeStyle = .medium
		return df
	}()

	init(model: ImageComment) {
		self.model = model
	}

	func view() -> UITableViewCell {
		let cell = ImageCommentCell()
		cell.messageLabel.text = model.message
		cell.authorNameLabel.text = model.author.username
		cell.createdAtLabel.text = dateFormatter.string(from: model.createdAt)
		return cell
	}
}

//
//  FeedImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Mario Alberto Barragán Espinosa on 12/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final class FeedImageCommentCellController {
	private let model: FeedImageComment

	init(model: FeedImageComment) {
		self.model = model
	}
	
	func view() -> UITableViewCell {
		let cell = FeedImageCommentCell()
		cell.messageLabel.text = model.message
		cell.authorNameLabel.text = model.author
		return cell
	}
}


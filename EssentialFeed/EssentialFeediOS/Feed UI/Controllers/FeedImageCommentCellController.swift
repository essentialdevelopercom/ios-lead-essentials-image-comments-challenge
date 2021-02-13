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
	private let viewModel: FeedImageCommentCellViewModel

	public init(viewModel: FeedImageCommentCellViewModel) {
		self.viewModel = viewModel
	}
	
	func view() -> UITableViewCell {
		let cell = binded(FeedImageCommentCell())
		return cell
	}
	
	private func binded(_ cell: FeedImageCommentCell) -> FeedImageCommentCell {
		cell.messageLabel.text = viewModel.message
		cell.authorNameLabel.text = viewModel.authorName
		return cell
	}
}


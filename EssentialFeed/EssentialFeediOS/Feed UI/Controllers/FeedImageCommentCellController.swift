//
//  FeedImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Mario Alberto Barragán Espinosa on 12/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedImageCommentCellController: FeedCommentView {
	private lazy var cell = FeedImageCommentCell()
	
	public init() {}
	
	func view() -> UITableViewCell {
		return cell
	}
	
	public func display(_ viewModel: FeedImageCommentCellViewModel) {
		cell.messageLabel.text = viewModel.message
		cell.authorNameLabel.text = viewModel.authorName
	}
}


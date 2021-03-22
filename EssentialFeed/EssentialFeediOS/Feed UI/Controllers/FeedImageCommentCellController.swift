//
//  FeedImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Ivan Ornes on 15/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedImageCommentCellControllerDelegate {
	func didRequestImageComment()
}

public class FeedImageCommentCellController: FeedImageCommentView {
	private let delegate: FeedImageCommentCellControllerDelegate
	private var cell: FeedImageCommentCell?
	
	public init(delegate: FeedImageCommentCellControllerDelegate) {
		self.delegate = delegate
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		delegate.didRequestImageComment()
		return cell!
	}
	
	public func display(_ viewModel: FeedImageCommentViewModel) {
		cell?.messageLabel.text = viewModel.message
		cell?.createdAtLabel.text = viewModel.creationDate
		cell?.authorLabel.text = viewModel.author
	}
}

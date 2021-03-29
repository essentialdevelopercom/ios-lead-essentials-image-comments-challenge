//
//  ImageCommentsCellController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public protocol ImageCommentCellControllerDelegate {
	func didRequestComment()
}

public final class ImageCommentsCellController: ImageCommentView {
	private let delegate: ImageCommentCellControllerDelegate
	private var cell: ImageCommentCell?
	
	public init(delegate: ImageCommentCellControllerDelegate) {
		self.delegate = delegate
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		delegate.didRequestComment()
		return cell!
	}
	
	public func display(_ viewModel: ImageCommentViewModel) {
		cell?.authorLabel?.text = viewModel.author
		cell?.messageLabel?.text = viewModel.message
		cell?.creationDateLabel?.text = viewModel.creationDate
	}
}

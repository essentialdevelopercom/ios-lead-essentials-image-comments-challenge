//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentCellController {
	private var cell: ImageCommentCell?
	private var viewModel: () -> ImageCommentViewModel
	
	public init(viewModel: @escaping () -> ImageCommentViewModel) {
		self.viewModel = viewModel
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		display(viewModel())
		return cell!
	}
	
	private func display(_ viewModel: ImageCommentViewModel) {
		cell?.authorUsername = viewModel.authorUsername
	}
}

//
//  ImageCommentsCellController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public final class ImageCommentsCellController {
	private let viewModel: ImageCommentViewModel
	
	public init(viewModel: ImageCommentViewModel) {
		self.viewModel = viewModel
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		cell.authorLabel?.text = viewModel.author
		cell.messageLabel?.text = viewModel.message
		cell.creationDateLabel?.text = viewModel.creationDate
		return cell
	}
}

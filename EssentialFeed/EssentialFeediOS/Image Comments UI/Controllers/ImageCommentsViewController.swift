//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Raphael Silva on 19/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public final class ImageCommentsViewController:
	UITableViewController,
	ImageCommentsView,
	ImageCommentsErrorView
{
	@IBOutlet
	private(set) public var errorView: ErrorView!


	private var viewModels = [ImageCommentViewModel]() {
		didSet {
			tableView.reloadData()
		}
	}

	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.sizeTableHeaderToFit()
	}

	public func display(
		_ viewModel: ImageCommentsViewModel
	) {
		viewModels = viewModel.comments
	}

	public func display(
		_ viewModel: ImageCommentsErrorViewModel
	) {
		errorView.message = viewModel.message
	}

	// MARK: - UITableViewDataSource

	public override func numberOfSections(
		in tableView: UITableView
	) -> Int {
		1
	}

	public override func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		viewModels.count
	}

	public override func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		let viewModel = viewModels[indexPath.row]
		cell.usernameLabel.text = viewModel.username
		cell.dateLabel.text = viewModel.date
		cell.messageLabel.text = viewModel.message
		return cell
	}
}

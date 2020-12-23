//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Cronay on 23.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol ImageCommentsViewControllerDelegate {
	func didRequestCommentsRefresh()
	func didCancelCommentsRequest()
}

public class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsErrorView, ImageCommentsLoadingView {
	@IBOutlet private(set) public var errorView: ErrorView?
	public var delegate: ImageCommentsViewControllerDelegate?

	var tableModel = [PresentableImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}

	public override func viewDidLoad() {
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

		refresh()
	}

	public override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		delegate?.didCancelCommentsRequest()
	}

	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.sizeTableHeaderToFit()
	}

	@objc private func refresh() {
		delegate?.didRequestCommentsRefresh()
	}

	public func display(_ viewModel: ImageCommentsViewModel) {
		tableModel = viewModel.presentables
	}

	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		errorView?.message = viewModel.message
	}

	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}

	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = tableModel[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell", for: indexPath) as! ImageCommentCell
		cell.dateLabel.text = model.date
		cell.usernameLabel.text = model.username
		cell.messageLabel.text = model.message
		return cell
	}
}

//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

protocol ImageCommentsViewControllerDelegate {
	func didRequestImageCommentsRefresh()
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsLoadingView {
	var delegate: ImageCommentsViewControllerDelegate?
	
	var tableModel = [ImageCommentCellController]() {
		didSet {
			tableView.reloadData()
		}
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		refresh()
	}

	@IBAction private func refresh() {
		delegate?.didRequestImageCommentsRefresh()
	}

	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}

	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		cellController(forRowAt: indexPath).view
	}

	private func cellController(forRowAt indexPath: IndexPath) -> ImageCommentCellController {
		tableModel[indexPath.row]
	}
}

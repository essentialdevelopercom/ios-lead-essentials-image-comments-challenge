//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol ImageCommentsViewControllerDelegate {
	func didRequestImageCommentsRefresh()
	func didCancelImageCommentsRequest()
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsLoadingView, ImageCommentsErrorView {
	@IBOutlet private(set) public var errorView: ErrorView?

	public var delegate: ImageCommentsViewControllerDelegate?
	
	private var tableModel = [ImageCommentCellController]() {
		didSet {
			tableView.reloadData()
		}
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		refresh()
	}

	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.sizeTableHeaderToFit()
	}

	public override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		delegate?.didCancelImageCommentsRequest()
	}

	@IBAction private func refresh() {
		delegate?.didRequestImageCommentsRefresh()
	}

	public func display(_ cellControllers: [ImageCommentCellController]) {
		tableModel = cellControllers
	}

	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}

	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		errorView?.message = viewModel.message
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}

	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		cellController(forRowAt: indexPath).view(in: tableView)
	}

	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		removeCellController(forRowAt: indexPath)
	}

	private func cellController(forRowAt indexPath: IndexPath) -> ImageCommentCellController {
		tableModel[indexPath.row]
	}

	private func removeCellController(forRowAt indexPath: IndexPath) {
		tableModel[indexPath.row].removeCell()
	}
}

//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentsViewController: UITableViewController {
	private var refreshController: ImageCommentsRefreshViewController?
	private var tableModel = [ImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	private var cellControllers = [IndexPath: ImageCommentCellController]()

	public convenience init(loader: ImageCommentsLoader) {
		self.init()
		self.refreshController = ImageCommentsRefreshViewController(imageCommentsLoader: loader)
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		refreshControl = refreshController?.view
		refreshController?.onRefresh = { [weak self] imageComments in
			self?.tableModel = imageComments
		}
		refreshController?.refresh()
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}

	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		cellController(forRowAt: indexPath).view()
	}

	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		removeCellController(forRowAt: indexPath)
	}

	private func cellController(forRowAt indexPath: IndexPath) -> ImageCommentCellController {
		let cellModel = tableModel[indexPath.row]
		let cellController = ImageCommentCellController(model: cellModel)
		cellControllers[indexPath] = cellController
		return cellController
	}

	private func removeCellController(forRowAt indexPath: IndexPath) {
		cellControllers[indexPath] = nil
	}
}

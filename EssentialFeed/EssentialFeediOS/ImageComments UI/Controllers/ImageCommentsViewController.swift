//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Sebastian Vidrea on 02.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public final class ImageCommentsViewController: UITableViewController {
	private var refreshController: ImageCommentsRefreshViewController?
	var tableModel = [ImageCommentCellController]() {
		didSet {
			tableView.reloadData()
		}
	}

	convenience init(refreshController: ImageCommentsRefreshViewController) {
		self.init()
		self.refreshController = refreshController
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		refreshControl = refreshController?.view
		refreshController?.refresh()
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

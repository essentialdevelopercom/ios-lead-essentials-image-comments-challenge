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

	private var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		df.timeStyle = .medium
		return df
	}()

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
		let cellModel = tableModel[indexPath.row]
		let cell = ImageCommentCell()
		cell.messageLabel.text = cellModel.message
		cell.authorNameLabel.text = cellModel.author.username
		cell.createdAtLabel.text = dateFormatter.string(from: cellModel.createdAt)
		return cell
	}
}

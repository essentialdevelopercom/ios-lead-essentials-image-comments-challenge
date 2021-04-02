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
	private var loader: ImageCommentsLoader?
	private var tableModel = [ImageComment]()

	private var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		df.timeStyle = .medium
		return df
	}()

	public convenience init(loader: ImageCommentsLoader) {
		self.init()
		self.loader = loader
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		load()
	}

	@objc private func load() {
		refreshControl?.beginRefreshing()
		loader?.load { [weak self] result in
			switch result {
			case let .success(imageComments):
				self?.tableModel = imageComments
				self?.tableView.reloadData()
				self?.refreshControl?.endRefreshing()

			case .failure:
				break
			}
		}
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

//
//  FeedImageCommentViewController.swift
//  EssentialFeediOS
//
//  Created by Mario Alberto Barragán Espinosa on 09/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final public class FeedImageCommentViewController: UITableViewController {
	private var feedCommentLoader: FeedImageCommentLoader?
	private var url: URL?
	
	private var tableModel = [FeedImageComment]()
	
	public convenience init(feedCommentLoader: FeedImageCommentLoader, url: URL) {
		self.init()
		self.feedCommentLoader = feedCommentLoader
		self.url = url
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		load()
	}
	
	@objc private func load() {
		refreshControl?.beginRefreshing()
		_ = feedCommentLoader?.loadImageCommentData(from: url!) { [weak self] result in
			if let feed = try? result.get() {
				self?.tableModel = feed
				self?.tableView.reloadData()

			}
			self?.refreshControl?.endRefreshing()
		}
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellModel = tableModel[indexPath.row]
		let cell = FeedImageCommentCell()
		cell.messageLabel.text = cellModel.message
		cell.authorNameLabel.text = cellModel.author
		return cell
	}
}

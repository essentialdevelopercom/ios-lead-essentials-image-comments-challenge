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
	private var refreshController: FeedImageCommentRefreshController?
	
	private var tableModel = [FeedImageComment]() {
		didSet { tableView.reloadData() }
	}
		
	public convenience init(feedCommentLoader: FeedImageCommentLoader, url: URL) {
		self.init()
		self.refreshController = FeedImageCommentRefreshController(feedCommentLoader: feedCommentLoader, url: url)
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = refreshController?.view
		refreshController?.onRefresh = { [weak self] feed in
			self?.tableModel = feed
		}
		refreshController?.refresh()
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellModel = tableModel[indexPath.row]
		let cellController = FeedImageCommentCellController(model: cellModel)
		return cellController.view()
	}
}

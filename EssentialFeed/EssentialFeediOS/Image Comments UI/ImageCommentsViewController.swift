//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 20/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public class ImageCommentsViewController: UITableViewController {

	private var refreshController: ImageCommentsRefreshController?
	
	var tableModel = [ImageCommentsCellController]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	convenience init(refreshController: ImageCommentsRefreshController) {
		self.init()
		self.refreshController = refreshController
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl = refreshController?.refreshView
		tableView.tableHeaderView = refreshController?.errorView
		refreshController?.refreshComments()
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellController = tableModel[indexPath.row]
		return cellController.view()
	}
}

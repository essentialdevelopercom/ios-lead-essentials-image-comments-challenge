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
	@IBOutlet private(set) public var refreshController: ImageCommentsRefreshController?
	
	private var tableModel = [ImageCommentsCellController]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refreshController?.refreshComments()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableView.sizeTableHeaderToFit()
	}
	
	public func display(_ cellControllers: [ImageCommentsCellController]) {
		self.tableModel = cellControllers
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellController = tableModel[indexPath.row]
		return cellController.view(in: tableView)
	}
}


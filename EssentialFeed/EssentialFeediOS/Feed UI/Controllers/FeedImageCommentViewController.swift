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
	private var loadingControllers = [IndexPath: FeedImageCommentCellController]()
	
	public var tableModel = [FeedImageCommentCellController]() {
		didSet { tableView.reloadData() }
	}
		
	public convenience init(refreshController: FeedImageCommentRefreshController) {
		self.init()
		self.refreshController = refreshController
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = refreshController?.view
		refreshController?.refresh()
	}
	
	public func display(_ cellControllers: [FeedImageCommentCellController]) {
		loadingControllers = [:]
		tableModel = cellControllers
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableModel[indexPath.row].view()
	}
}

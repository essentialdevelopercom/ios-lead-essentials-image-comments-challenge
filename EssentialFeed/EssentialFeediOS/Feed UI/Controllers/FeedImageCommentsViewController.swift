//
//  FeedImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Ivan Ornes on 15/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public class FeedImageCommentsViewController: UITableViewController {
	
	private var loadingControllers = [IndexPath: FeedImageCommentCellController]()
	
	private var tableModel = [FeedImageCommentCellController]() {
		didSet { tableView.reloadData() }
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	@IBAction private func refresh() {
	}
	
	public func display(_ cellControllers: [FeedImageCommentCellController]) {
		loadingControllers = [:]
		tableModel = cellControllers
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return cellController(forRowAt: indexPath).view(in: tableView)
	}
	
	private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCommentCellController {
		let controller = tableModel[indexPath.row]
		loadingControllers[indexPath] = controller
		return controller
	}
}
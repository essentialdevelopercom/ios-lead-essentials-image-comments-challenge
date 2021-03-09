//
//  FeedImageCommentsController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 05.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public final class FeedImageCommentsController: UITableViewController {
	
	var refreshController: FeedImageCommentsRefreshController!
	var cellControllers = [FeedImageCommentCellController]() {
		didSet { tableView.reloadData() }
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
			
		refreshControl = refreshController.view
		refreshController.refresh()
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cellControllers.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return cellControllers[indexPath.row].view(for: tableView)
	}
}

//
//  FeedImageCommentsController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 05.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

protocol FeedImageCommentsControllerDelegate {
	func didRequestCommentsRefresh()
}

public final class FeedImageCommentsController: UITableViewController, FeedImageCommentLoadingView {
	var delegate: FeedImageCommentsControllerDelegate?
	
	var cellControllers = [FeedImageCommentCellController]() {
		didSet { tableView.reloadData() }
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
			
		refresh()
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestCommentsRefresh()
	}
	
	func display(_ viewModel: FeedImageCommentLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cellControllers.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return cellControllers[indexPath.row].view(for: tableView)
	}
}

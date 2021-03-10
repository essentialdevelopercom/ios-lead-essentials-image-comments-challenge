//
//  CommentsController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 05.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

protocol CommentsControllerDelegate {
	func didRequestCommentsRefresh()
}

public final class CommentsController: UITableViewController, CommentLoadingView {
	var delegate: CommentsControllerDelegate?
	
	var cellControllers = [CommentCellController]() {
		didSet { tableView.reloadData() }
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
			
		refresh()
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestCommentsRefresh()
	}
	
	func display(_ viewModel: CommentLoadingViewModel) {
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

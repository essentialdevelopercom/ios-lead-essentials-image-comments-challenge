//
//  CommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol CommentsViewControllerDelegate {
	func didRequestCommentsRefresh()
}

public class CommentsViewController: UITableViewController, CommentView, CommentLoadingView, CommentErrorView {
	
	@IBOutlet private(set) public var errorView: ErrorView!
	
	public var delegate: CommentsViewControllerDelegate?
	
	var tableModel = [PresentableComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestCommentsRefresh()
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refresh()
    }
	
    // MARK: - Table view data source

	public override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
    }

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return tableModel.count
    }
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = tableModel[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
		cell.dateLabel.text = model.date
		cell.usernameLabel.text = model.username
		cell.messageLabel.text = model.message
		return cell
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.sizeTableHeaderToFit()
	}

	public func display(_ viewModel: CommentViewModel) {
		tableModel = viewModel.comments
	}
	
	public func display(_ viewModel: CommentLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}
	
	public func display(_ viewModel: CommentErrorViewModel) {
		errorView?.message = viewModel.message
	}
}

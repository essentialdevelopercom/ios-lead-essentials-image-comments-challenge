//
//  CommentViewController.swift
//  EssentialFeediOS
//
//  Created by Khoi Nguyen on 30/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed


final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?
	
	init(_ object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: CommentLoadingView where T: CommentLoadingView {
	func display(_ viewModel: CommentLoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: CommentView where T: CommentView {
	func display(_ viewModel: CommentViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: CommentErrorView where T: CommentErrorView {
	func display(_ viewModel: CommentErrorViewModel) {
		object?.display(viewModel)
	}
}

protocol CommentViewControllerDelegate {
	func loadComment()
}

public final class CommentViewController: UITableViewController, CommentErrorView, CommentLoadingView {
	var delegate: CommentViewControllerDelegate?
	var tableModel = [CommentCellController]() {
		didSet {
			tableView.reloadData()
		}
	}
	@IBOutlet private(set) public var errorView: ErrorView?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refresh()
	}
	
	@IBAction private func refresh() {
		delegate?.loadComment()
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableModel[indexPath.row].view(in: tableView)
	}
	
	public func display(_ viewModel: CommentErrorViewModel) {
	}
	
	public func display(_ viewModel: CommentLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}
}

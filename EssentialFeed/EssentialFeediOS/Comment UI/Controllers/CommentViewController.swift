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

public protocol CommentViewControllerDelegate {
	func didRequestCommentRefresh()
	func didCancelCommentRequest()
}

public final class CommentViewController: UITableViewController, CommentErrorView, CommentLoadingView {
	var delegate: CommentViewControllerDelegate?
	
	private var tableModel = [CommentCellController]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	@IBOutlet private(set) public var errorView: ErrorView?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refresh()
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		delegate?.didCancelCommentRequest()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestCommentRefresh()
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableModel[indexPath.row].view(in: tableView)
	}
	
	public func display(_ viewModel: CommentErrorViewModel) {
		errorView?.message = viewModel.message
	}
	
	public func display(_ viewModel: CommentLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}
	
	public func display(_ cellControllers: [CommentCellController]) {
		tableModel = cellControllers
	}
}

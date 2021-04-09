//
//  CommentsController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 05.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol CommentsControllerDelegate {
	func didRequestCommentsRefresh()
}

public final class CommentsController: UITableViewController, CommentErrorView, CommentLoadingView {
	public var delegate: CommentsControllerDelegate?
	@IBOutlet private(set) public var errorView: ErrorView?
	
	private var tableModel = [CommentCellController]() {
		didSet { tableView.reloadData() }
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	public func display(_ cellControllers: [CommentCellController]) {
		tableModel = cellControllers
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestCommentsRefresh()
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
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableModel[indexPath.row].view(for: tableView)
	}
}

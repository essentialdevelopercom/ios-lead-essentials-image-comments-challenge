//
//  FeedImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Ivan Ornes on 15/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedImageCommentsViewControllerDelegate {
	func didRequestFeedImageCommentsRefresh()
	func didRequestFeedImageCommentsCancel()
}

public class FeedImageCommentsViewController: UITableViewController, FeedLoadingView, FeedErrorView {
	@IBOutlet private(set) public var errorView: ErrorView?
	
	private var loadingControllers = [IndexPath: FeedImageCommentCellController]()
	
	private var tableModel = [FeedImageCommentCellController]() {
		didSet { tableView.reloadData() }
	}
	
	public var delegate: FeedImageCommentsViewControllerDelegate?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		delegate?.didRequestFeedImageCommentsCancel()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestFeedImageCommentsRefresh()
	}
	
	public func display(_ cellControllers: [FeedImageCommentCellController]) {
		loadingControllers = [:]
		tableModel = cellControllers
	}
	
	public func display(_ viewModel: FeedLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public func display(_ viewModel: FeedErrorViewModel) {
		errorView?.message = viewModel.message
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

//
//  FeedImageCommentViewController.swift
//  EssentialFeediOS
//
//  Created by Mario Alberto Barragán Espinosa on 09/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedImageCommentViewControllerDelegate {
	func didRequestFeedCommentRefresh()
}

final public class FeedImageCommentViewController: UITableViewController, FeedLoadingView, FeedErrorView {
	private(set) public var errorView = ErrorView()
	public var delegate: FeedImageCommentViewControllerDelegate?
	
	public var tableModel = [FeedImageCommentCellController]() {
		didSet { tableView.reloadData() }
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
		
		tableView.tableHeaderView = errorView.makeContainer()
		errorView.onHide = { [weak self] in
			self?.tableView.beginUpdates()
			self?.tableView.sizeTableHeaderToFit()
			self?.tableView.endUpdates()
		}
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestFeedCommentRefresh()
	}
	
	public func display(_ cellControllers: [FeedImageCommentCellController]) {
		tableModel = cellControllers
	}
	
	public func display(_ viewModel: FeedLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public func display(_ viewModel: FeedErrorViewModel) {
		errorView.message = viewModel.message
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableModel[indexPath.row].view(in: tableView)
	}
}

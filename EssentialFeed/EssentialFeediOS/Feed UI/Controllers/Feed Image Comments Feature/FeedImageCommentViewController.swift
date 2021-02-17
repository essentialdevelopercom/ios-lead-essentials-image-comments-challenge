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

final public class FeedImageCommentViewController: UITableViewController, FeedLoadingView {
	public var delegate: FeedImageCommentViewControllerDelegate?
	private var loadingControllers = [IndexPath: FeedImageCommentCellController]()
	
	public var tableModel = [FeedImageCommentCellController]() {
		didSet { tableView.reloadData() }
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestFeedCommentRefresh()
	}
	
	public func display(_ cellControllers: [FeedImageCommentCellController]) {
		loadingControllers = [:]
		tableModel = cellControllers
	}
	
	public func display(_ viewModel: FeedLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableModel[indexPath.row].view()
	}
}

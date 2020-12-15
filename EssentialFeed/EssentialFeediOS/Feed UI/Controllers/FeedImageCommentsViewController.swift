//
//  FeedImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Maxim Soldatov on 11/29/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedImageCommentsViewControllerDelegate {
	func didRequestCommentsRefresh()
}

final public class FeedImageCommentsViewController: UITableViewController {
	
	@IBOutlet private(set) public var errorView: ErrorView?
	public var delegate: FeedImageCommentsViewControllerDelegate?
	
	var models = [FeedImageCommentPresentingModel]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		refresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		return models.count
	}
	
	override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCommentCell") as! FeedImageCommentCell
		let model = models[indexPath.row]
		cell.display(model)
		
		return cell
	}
	
	@IBAction func refresh() {
		delegate?.didRequestCommentsRefresh()
	}
}

extension FeedImageCommentsViewController: FeedImageCommentsView {
	public func display(_ viewModel: FeedImageCommentsViewModel) {
		models = viewModel.comments
	}
}

extension FeedImageCommentsViewController: FeedImageCommentsErrorView {
	public func display(_ viewModel: FeedImageCommentErrorViewModel) {
		errorView?.message = viewModel.message
	}
}

extension FeedImageCommentsViewController: FeedImageCommentsLoadingView {
	public func display(_ viewModel: FeedImageCommentLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}
}


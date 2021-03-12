//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Eric Garlock on 3/11/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol ImageCommentsViewControllerDelegate {
	func didRequestImageCommentsRefresh()
}

public class ImageCommentsViewController : UITableViewController, ImageCommentView, ImageCommentLoadingView, ImageCommentErrorView {
	
	public var delegate: ImageCommentsViewControllerDelegate?
	
	@IBOutlet var errorView: ErrorView!
	
	private var tableModel = [ImageCommentViewModel]() {
		didSet { tableView.reloadData() }
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
		
		refresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	@objc public func refresh() {
		delegate?.didRequestImageCommentsRefresh()
	}
	
	public func display(_ viewModel: ImageCommentsViewModel) {
		tableModel = viewModel.comments
	}
	
	public func display(_ viewModel: ImageCommentLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}
	
	public func display(_ viewModel: ImageCommentErrorViewModel) {
		errorView.message = viewModel.message
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = tableModel[indexPath.row]
		
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		cell.configure(model)
		return cell
	}
}

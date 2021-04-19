//
//  FeedCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Danil Vassyakin on 3/31/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedCommentsViewViewControllerDelegate {
	func didRequestCommentsRefresh()
}

public final class FeedCommentsViewController: UITableViewController, FeedImageCommentView, FeedImageCommentLoadingView, FeedImageCommentErrorView {

	public var delegate: FeedCommentsViewViewControllerDelegate?
	@IBOutlet weak var errorView: ErrorView!
	
	private var tableModel = [PresentationImageComment]() {
		didSet { tableView.reloadData() }
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableView.sizeTableHeaderToFit()
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestCommentsRefresh()
	}
	
	public func display(_ viewModel: FeedImageCommentLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public func display(_ viewModel: FeedImageCommentViewModel) {
		tableModel = viewModel.comments
	}

	public func display(_ viewModel: FeedImageCommentErrorViewModel) {
		errorView?.message = viewModel.message
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = tableModel[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedCommentCell
		cell.configure(authorName: model.author, commentDate: model.createdAt, commentText: model.message)
		return cell
	}
	
}

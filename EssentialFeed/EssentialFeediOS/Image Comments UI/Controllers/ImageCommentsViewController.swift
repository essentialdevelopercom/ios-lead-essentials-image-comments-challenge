//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public protocol ImageCommentsViewControllerDelegate {
	func didRequestCommentsRefresh()
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsErrorView, ImageCommentsLoadingView {
	
	@IBOutlet private(set) public var errorView: ErrorView?
	
	public var delegate: ImageCommentsViewControllerDelegate?
	
	var models = [PresentableImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
	}
	
	@IBAction func refresh() {
		delegate?.didRequestCommentsRefresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	public func display(_ viewModel: ImageCommentsViewModel) {
		models = viewModel.comments
	}
	
	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		errorView?.message = viewModel.message
	}
	
	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	override public func numberOfSections(in _: UITableView) -> Int {
		return 1
	}
	
	override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		return models.count
	}
	
	override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		let model = models[indexPath.row]
		cell.usernameLabel?.text = model.author
		cell.createdAtLabel?.text = model.createdAt
		cell.commentLabel?.text = model.message
		cell.selectionStyle = .none
		return cell
	}
}

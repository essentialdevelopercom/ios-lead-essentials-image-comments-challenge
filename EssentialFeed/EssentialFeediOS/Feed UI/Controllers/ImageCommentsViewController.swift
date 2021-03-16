//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 08/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public struct ImageCommentViewModel {
	public let authorUsername: String
	
	public init(authorUsername: String) {
		self.authorUsername = authorUsername
	}
}


public final class ImageCommentCellController {
	private var cell: ImageCommentCell?
	private var viewModel: () -> ImageCommentViewModel
	
	public init(viewModel: @escaping () -> ImageCommentViewModel) {
		self.viewModel = viewModel
	}
	
	func view(in tableView: UITableView) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		display(viewModel())
		return cell!
	}
	
	private func display(_ viewModel: ImageCommentViewModel) {
		cell?.authorUsername = viewModel.authorUsername
	}
}

public protocol ImageCommentsViewControllerDelegate {
	func didRequestImageCommentsRefresh()
	func didCancelImageCommentsLoading()
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsErrorView, ImageCommentsLoadingView {
	
	@IBOutlet private(set) public var errorView: ErrorView?
	
	private var tableModel = [ImageCommentCellController]() {
		didSet { tableView.reloadData() }
	}
	
	public var delegate: ImageCommentsViewControllerDelegate?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
	}
	
	deinit {
		cancelImageLoadingTask()
	}
	
	public func cancelImageLoadingTask() {
		delegate?.didCancelImageCommentsLoading()
	}
	
	public func display(_ cellControllers: [ImageCommentCellController]) {
		tableModel = cellControllers
	}
	
	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		errorView?.message = viewModel.message
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestImageCommentsRefresh()
	}
	
	// MARK: - Table View DataSource
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		cellController(for: indexPath).view(in: tableView)
	}
	
	private func cellController(for indexPath: IndexPath) -> ImageCommentCellController {
		tableModel[indexPath.row]
	}
	
}

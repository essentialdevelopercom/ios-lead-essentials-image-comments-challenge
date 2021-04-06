//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 08/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol ImageCommentsViewControllerDelegate {
	func didRequestImageCommentsRefresh()
	func didUserInteractWithErrorMessage()
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
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
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
	
	@IBAction func dismissErrorView() {
		delegate?.didUserInteractWithErrorMessage()
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

//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Adrian Szymanowski on 08/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentCell: UITableViewCell {
	
}

public final class ImageCommentCellController {
	public init() {}
}

public protocol ImageCommentsViewControllerDelegate {
	func didRequestImageCommentsRefresh()
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsErrorView, ImageCommentsLoadingView {
	
	private var tableModel = [ImageCommentCellController]() {
		didSet { tableView.reloadData() }
	}
	
	public var delegate: ImageCommentsViewControllerDelegate?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
	}
	
	public func display(_ cellControllers: [ImageCommentCellController]) {
		tableModel = cellControllers
	}
	
	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestImageCommentsRefresh()
	}
	
	// MARK: - Table View DataSource
	public override func numberOfSections(in tableView: UITableView) -> Int {
		1
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		UITableViewCell()
	}
	
}

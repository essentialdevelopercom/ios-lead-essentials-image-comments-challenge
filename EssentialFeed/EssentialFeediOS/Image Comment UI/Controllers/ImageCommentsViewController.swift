//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Alok Subedi on 06/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import UIKit
import EssentialFeed

public protocol ImageCommentsViewControllerDelegate {
	func didRequestImageCommentsRefresh()
}

public class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView {
	@IBOutlet private(set) public var errorView: ErrorView?
	
	public var delegate: ImageCommentsViewControllerDelegate?
	private var imageComments = [PresentableImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		load()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	@IBAction private func load() {
		delegate?.didRequestImageCommentsRefresh()
	}
	
	public func display(_ viewModel: ImageCommentsViewModel) {
		self.imageComments = viewModel.comments
	}
	
	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		if let errorMessage = viewModel.message {
			errorView?.message = errorMessage
		} else {
			errorView?.message = nil
		}
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return imageComments.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = imageComments[indexPath.row]
		let cell: ImageCommentsCell = tableView.dequeueReusableCell()
		cell.usernameLabel.text = model.username
		cell.createdTimeLabel.text = model.date
		cell.message.text = model.message
		
		return cell
	}
}

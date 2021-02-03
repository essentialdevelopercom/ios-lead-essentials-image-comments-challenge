//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Lukas Bahrle Santana on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol ImageCommentsControllerDelegate {
	func didRequestImageCommentsRefresh()
	func didRequestImageCommentsCancel()
}


public class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsLoadingView, ImageCommentsErrorView{
	
	@IBOutlet private(set) public var errorView: ErrorView!
	
	public var delegate: ImageCommentsControllerDelegate?
	
	var loaderTask:ImageCommentsLoaderTask?
	
	private var imageComments = [PresentableImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		self.refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
		
		refresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.delegate?.didRequestImageCommentsCancel()
	}
	
	@objc private func refresh() {
		self.delegate?.didRequestImageCommentsRefresh()
	}
	
	public func display(_ viewModel: ImageCommentsViewModel) {
		imageComments = viewModel.imageComments
	}
	
	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading{
			self.refreshControl?.beginRefreshing()
		}
		else{
			self.refreshControl?.endRefreshing()
		}
	}
	
	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		errorView.message = viewModel.message
	}
	
	// MARK: - Table View
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return imageComments.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		cell.configure(imageComment: imageComments[indexPath.row])
		
		return cell
	}
}

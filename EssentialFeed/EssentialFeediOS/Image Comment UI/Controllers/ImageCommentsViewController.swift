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
	private var delegate: ImageCommentsViewControllerDelegate?
	private var imageComments = [ImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	private lazy var errorLabel: UILabel = {
		let label = UILabel()
		return label
	}()
	
	convenience public init(delegate: ImageCommentsViewControllerDelegate) {
		self.init()
		self.delegate = delegate
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.tableHeaderView = errorLabel
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		
		load()
	}
	
	@objc func load() {
		delegate?.didRequestImageCommentsRefresh()
	}
	
	public func display(_ viewModel: ImageCommentsViewModel) {
		self.refreshControl?.endRefreshing()
		self.imageComments = viewModel.comments
	}
	
	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading {
			self.refreshControl?.beginRefreshing()
		} else {
			self.refreshControl?.endRefreshing()
		}
	}
	
	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		if let errorMessage = viewModel.message {
			self.refreshControl?.endRefreshing()
			self.errorLabel.text = errorMessage
		} else {
			self.errorLabel.text = nil
		}
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return imageComments.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = imageComments[indexPath.row]
		let cell = ImageCommentsCell()
		cell.usernameLabel.text = model.author.username
		cell.createdTimeLabel.text = relativeDateStringFromNow(to: model.createdDate)
		cell.message.text = model.message
		
		return cell
	}
	
	private func relativeDateStringFromNow(to date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let relativeDateString = formatter.localizedString(for: date, relativeTo: Date())
		return relativeDateString
	}
}

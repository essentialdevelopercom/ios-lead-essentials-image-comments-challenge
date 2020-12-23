//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Cronay on 23.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsErrorView, ImageCommentsLoadingView {

	public let errorView = UILabel()

	var loader: ImageCommentsLoader?
	var presenter: ImageCommentsPresenter?
	var tableModel = [PresentableImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	var task: ImageCommentsLoaderTask?

	public override func viewDidLoad() {
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

		tableView.register(ImageCommentCell.self, forCellReuseIdentifier: "ImageCommentCell")

		refresh()
	}

	public override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		task?.cancel()
	}

	@objc private func refresh() {
		presenter?.didStartLoadingComments()
		task = loader?.load { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingComments(with: comments)
			case let .failure(error):
				self?.presenter?.didFinishLoadingComments(with: error)
			}
		}
	}

	public func display(_ viewModel: ImageCommentsViewModel) {
		tableModel = viewModel.presentables
	}

	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		errorView.text = viewModel.message
	}

	public func display(_ viewModel: ImageCommentsLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}

	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = tableModel[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell", for: indexPath) as! ImageCommentCell
		cell.usernameLabel.text = model.username
		cell.messageLabel.text = model.message
		cell.dateLabel.text = model.date
		return cell
	}
}

//
//  CommentViewController.swift
//  EssentialFeediOS
//
//  Created by Khoi Nguyen on 30/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public struct PresentableComment {
	public init(id: UUID, message: String, createAt: String, author: String) {
		self.id = id
		self.message = message
		self.createAt = createAt
		self.author = author
	}
	
	public let id: UUID
	public let message: String
	public let createAt: String
	public let author: String
}



final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?
	
	init(_ object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: CommentLoadingView where T: CommentLoadingView {
	func display(_ viewModel: CommentLoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: CommentView where T: CommentView {
	func display(_ viewModel: CommentViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: CommentErrorView where T: CommentErrorView {
	func display(_ viewModel: CommentErrorViewModel) {
		object?.display(viewModel)
	}
}
class CommentLoaderPresentationAdapter: CommentViewControllerDelegate {
	private let commentLoader: CommentLoader
	var presenter: CommentPresenter?
	var delegate: CommentViewControllerDelegate?
	
	init(commentLoader: CommentLoader) {
		self.commentLoader = commentLoader
	}
	
	func loadComment() {
		presenter?.didStartLoadingComment()
		commentLoader.load { [weak self] result in
			switch result {
			case let .success(comments):
				self?.presenter?.didFinishLoadingComment(with: comments)
			case let .failure(error):
				self?.presenter?.didFinishLoadingComment(with: error)
			}
		}
	}
}


protocol CommentViewControllerDelegate {
	func loadComment()
}

public final class CommentViewController: UITableViewController, CommentView, CommentErrorView, CommentLoadingView {
	var delegate: CommentViewControllerDelegate?
	var tableModel = [CommentCellController]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refresh()
	}
	
	@IBAction private func refresh() {
		delegate?.loadComment()
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableModel[indexPath.row].view(in: tableView)
	}
	
	public func display(_ viewModel: CommentViewModel) {
	}
	
	public func display(_ viewModel: CommentErrorViewModel) {
	}
	
	public func display(_ viewModel: CommentLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}
}

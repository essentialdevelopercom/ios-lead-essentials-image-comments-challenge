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

public final class CommentUIComposer {
	private init() {}
	
	public static func commentComposeWith(loader: CommentLoader) -> CommentViewController {
		let presentationAdapter = CommentLoaderPresentationAdapter(commentLoader: loader)
		 
		let bundle = Bundle(for: CommentViewController.self)
		let storyBoard = UIStoryboard(name: "Comment", bundle: bundle)
		let commentViewController = storyBoard.instantiateInitialViewController() as! CommentViewController
		commentViewController.delegate = presentationAdapter
		let presenter = CommentPresenter(
			loadingView: WeakRefVirtualProxy(commentViewController),
			errorView: WeakRefVirtualProxy(commentViewController),
			commentView: CommentViewAdapter(controller: commentViewController))
		presentationAdapter.presenter = presenter
		
		return commentViewController
	}
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

private class CommentViewAdapter: CommentView {
	private weak var controller: CommentViewController?
	
	init(controller: CommentViewController) {
		self.controller = controller
	}
	
	func display(_ viewModel: CommentViewModel) {
		controller?.tableModel = viewModel.comments.map {
			CommentCellController(model: $0)
		}
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

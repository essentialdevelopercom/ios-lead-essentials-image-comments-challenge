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

public class CommentCell: UITableViewCell {
	public let authorLabel = UILabel()
	public let commentLabel = UILabel()
	public let timestampLabel = UILabel()
}

final class CommentRefreshViewController: NSObject, CommentLoadingView {
	
	
	private(set) lazy var view: UIRefreshControl = {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}()
	private let loader: CommentLoader
	
	init(loader: CommentLoader) {
		self.loader = loader
	}
	var onRefresh: (([Comment]) -> Void)?
	@objc func refresh() {
		view.beginRefreshing()
		
		loader.load { [weak self] result in
			if let comments = try? result.get() {
				self?.onRefresh?(comments)
			}
			self?.view.endRefreshing()
		}
	}
	
	func display(_ viewModel: CommentLoadingViewModel) {
		if viewModel.isLoading {
			view.beginRefreshing()
		} else {
			view.endRefreshing()
		}
	}
}

final class CommentCellController {
	private let model: Comment
	
	init(model: Comment) {
		self.model = model
	}
	
	func view() -> UITableViewCell {
		let cell = CommentCell()
		cell.authorLabel.text = model.author.username
		cell.timestampLabel.text = "any date"
		cell.commentLabel.text = model.message
		
		return cell
	}
}

public final class CommentUIComposer {
	private init() {}
	
	public static func commentComposeWith(loader: CommentLoader) -> CommentViewController {
		let refreshController = CommentRefreshViewController(loader: loader)
		let commentViewController = CommentViewController(refreshViewController: refreshController)
		refreshController.onRefresh = adaptCommentToCellControllers(forwardingTo: commentViewController)
		return commentViewController
	}

	private static func adaptCommentToCellControllers(forwardingTo controller: CommentViewController) -> ([Comment]) -> Void {
		return {[weak controller] comments in
			controller?.tableModel = comments.map {
				CommentCellController(model: $0)
			}
		}
	}
}

public final class CommentViewController: UITableViewController {
	var tableModel = [CommentCellController]() {
		didSet {
			tableView.reloadData()
		}
	}
	private var refreshController: CommentRefreshViewController?
	convenience init(refreshViewController: CommentRefreshViewController) {
		self.init()
		self.refreshController = refreshViewController
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl = refreshController?.view
		refreshController?.refresh()
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return tableModel[indexPath.row].view()
	}
}

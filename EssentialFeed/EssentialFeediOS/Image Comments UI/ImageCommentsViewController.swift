//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 20/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

public class ImageCommentCell: UITableViewCell {
	public let authorLabel = UILabel()
	public let creationDateLabel = UILabel()
	public let messageLabel = UILabel()
}

public class CommentErrorView: UIView {
	private(set) public lazy var button: UIButton = makeButton()
	
	public var message: String? {
		get { return button.title(for: .normal) }
	}
	
	private var isVisible: Bool { alpha > 0}
	
	func show(message: String) {
		button.setTitle(message, for: .normal)
	}
	
	@objc func hideMessage() {
		button.setTitle(nil, for: .normal)
		alpha = 0
	}
	
	private func makeButton() -> UIButton {
		let button = UIButton()
		button.setTitle(nil, for: .normal)
		button.addTarget(self, action: #selector(hideMessage), for: .touchUpInside)
		return button
	}
}

final class ImageCommentsRefreshController: NSObject {
	lazy var refreshView: UIRefreshControl = makeRefreshControl()
	lazy var errorView: CommentErrorView = makeErrorView()
	
	private let loader: ImageCommentLoader
	private let url: URL
	private var task: ImageCommentLoaderTask?
	
	var onCommentsLoad: ((_ comments: [ImageComment]) -> Void)?
	
	init(url: URL, loader: ImageCommentLoader) {
		self.url = url
		self.loader = loader
	}
	
	deinit {
		task?.cancel()
	}
	
	private func makeRefreshControl() -> UIRefreshControl {
		let control = UIRefreshControl()
		control.addTarget(self, action: #selector(refreshComments), for: .valueChanged)
		return control
	}
	
	private func makeErrorView() -> CommentErrorView {
		let view = CommentErrorView()
		return view
	}
	
	@objc func refreshComments() {
		refreshView.beginRefreshing()
		errorView.hideMessage()
		task = loader.load(from: url) { [weak self] result in
			switch result {
			case let .success(comments):
				self?.onCommentsLoad?(comments)
			case .failure:
				self?.errorView.show(message: "Couldn't connect to server")
			}
			self?.refreshView.endRefreshing()
			self?.task = nil
		}
	}
}

final class ImageCommentsCellController {
	private let model: ImageComment
	private let currentDate: () -> Date
	
	init(model: ImageComment, currentDate: @escaping () -> Date) {
		self.model = model
		self.currentDate = currentDate
	}
	
	func view() -> UITableViewCell {
		let cell = ImageCommentCell()
		cell.authorLabel.text = model.author
		cell.messageLabel.text = model.message
		cell.creationDateLabel.text = formatRelativeDate(for: model.creationDate)
		return cell
	}
	
	private func formatRelativeDate(for date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		return formatter.localizedString(for: date, relativeTo: currentDate())
	}
}

public final class ImageCommentsUIComposer {
	
	private init() {} 
	
	public static func imageCommentsComposedWith(url: URL, currentDate: @escaping () -> Date, loader: ImageCommentLoader) -> ImageCommentsViewController {
		let refreshController = ImageCommentsRefreshController(url: url, loader: loader)
		let viewController = ImageCommentsViewController(refreshController: refreshController)
		refreshController.onCommentsLoad = { [weak viewController] comments in
			viewController?.tableModel = comments.map {
				ImageCommentsCellController(model: $0, currentDate: currentDate)
			}
		}
		return viewController
	}
}

public class ImageCommentsViewController: UITableViewController {

	private var refreshController: ImageCommentsRefreshController?
	
	var tableModel = [ImageCommentsCellController]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	convenience init(refreshController: ImageCommentsRefreshController) {
		self.init()
		self.refreshController = refreshController
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl = refreshController?.refreshView
		tableView.tableHeaderView = refreshController?.errorView
		refreshController?.refreshComments()
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellController = tableModel[indexPath.row]
		return cellController.view()
	}
}


//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 20/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

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


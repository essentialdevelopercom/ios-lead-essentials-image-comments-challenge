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

public class ImageCommentsViewController: UITableViewController {
	private var url: URL!
	private var currentDate: (() -> Date)!
	private var loader: ImageCommentLoader?
	
	private var tableModel = [ImageComment]()
	
	public convenience init(url: URL, currentDate: @escaping () -> Date, loader: ImageCommentLoader) {
		self.init()
		self.url = url
		self.currentDate = currentDate
		self.loader = loader
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)

		load()
	}
	
	@objc private func load() {
		refreshControl?.beginRefreshing()
		_ = loader?.load(from: url) { [weak self] result in
			if let comments = try? result.get() {
				self?.tableModel = comments
				self?.tableView.reloadData()
			}
			self?.refreshControl?.endRefreshing()
		}
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellModel = tableModel[indexPath.row]
		let cell = ImageCommentCell()
		cell.authorLabel.text = cellModel.author
		cell.messageLabel.text = cellModel.message
		cell.creationDateLabel.text = formatRelativeDate(for: cellModel.creationDate)
		return cell
	}
	
	private func formatRelativeDate(for date: Date) -> String {
		let formatter = RelativeDateTimeFormatter()
		return formatter.localizedString(for: date, relativeTo: currentDate())
	}
}


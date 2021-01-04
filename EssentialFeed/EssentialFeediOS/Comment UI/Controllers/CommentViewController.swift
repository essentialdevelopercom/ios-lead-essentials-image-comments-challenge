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

public class CommentViewController: UITableViewController {
	private var loader: CommentLoader?
	private var tableModel = [Comment]()
	
	public convenience init(loader: CommentLoader) {
		self.init()
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
		
		loader?.load { [weak self] result in
			if let comments = try? result.get() {
				self?.tableModel = comments
				self?.tableView.reloadData()
			}
			self?.refreshControl?.endRefreshing()
		}
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = tableModel[indexPath.row]
		let cell = CommentCell()
		cell.authorLabel.text = model.author.username
		cell.timestampLabel.text = "any date"
		cell.commentLabel.text = model.message
		
		return cell
	}
}

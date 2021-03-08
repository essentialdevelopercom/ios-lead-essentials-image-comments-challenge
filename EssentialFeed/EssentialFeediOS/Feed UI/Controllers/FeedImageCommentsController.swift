//
//  FeedImageCommentsController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 05.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedImageCommentsController: UITableViewController {
	
	public var loader: FeedImageCommentsLoader!
	private var comments = [FeedImageComment]()
	
	public convenience init(loader: FeedImageCommentsLoader) {
		self.init()
		self.loader = loader
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		load()
	}
	
	@objc private func load() {
		refreshControl?.beginRefreshing()
		loader.load { [weak self] result in
			switch result {
			case let .success(comments):
				self?.comments = comments
				self?.tableView.reloadData()
				self?.refreshControl?.endRefreshing()
			case .failure:
				break
			}
		}
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return comments.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let comment = comments[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCommentCell") as! FeedImageCommentCell
		cell.authorLabel.text = comment.author.username
		cell.dateLabel.text = comment.createdAt
		cell.commentLabel.text = comment.message
		return cell
	}
}

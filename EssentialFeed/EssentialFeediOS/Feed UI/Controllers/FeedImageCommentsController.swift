//
//  FeedImageCommentsController.swift
//  EssentialFeediOS
//
//  Created by Anton Ilinykh on 05.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedImageCommentsRefreshController: NSObject {
	private(set) lazy var view: UIRefreshControl = {
		let view = UIRefreshControl()
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)
		return view
	}()
	
	private let commentsLoader: FeedImageCommentsLoader
	
	public init(commentsLoader: FeedImageCommentsLoader) {
		self.commentsLoader = commentsLoader
	}
	
	var onRefresh: (([FeedImageComment]) -> Void)?
	
	@objc func refresh() {
		view.beginRefreshing()
		commentsLoader.load { [weak self] result in
			if let comments = try? result.get() {
				self?.onRefresh?(comments)
			}
			self?.view.endRefreshing()
		}
	}
}

public final class FeedImageCommentsController: UITableViewController {
	
	public var refreshController: FeedImageCommentsRefreshController!
	private var comments = [FeedImageComment]() {
		didSet { tableView.reloadData() }
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
			
		refreshControl = refreshController.view
		refreshController.onRefresh = { [weak self] comments in
			self?.comments = comments
		}
		refreshController.refresh()
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

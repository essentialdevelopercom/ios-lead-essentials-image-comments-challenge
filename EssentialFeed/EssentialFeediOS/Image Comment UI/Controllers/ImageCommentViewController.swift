//
//  ImageCommentViewController.swift
//  EssentialFeediOS
//
//  Created by Antonio Mayorga on 4/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import UIKit
import EssentialFeed

public final class ImageCommentViewController: UITableViewController {
	@IBOutlet public weak var errorView: UIView!
	
	public var loader: ImageCommentLoader?
	private var tableModel = [ImageComment]()
	private var loadCommentTask: ImageCommentLoaderTask?
	
	public convenience init(loader: ImageCommentLoader) {
		self.init()
		self.loader = loader
	}
	
	deinit {
		loadCommentTask?.cancel()
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		title = NSLocalizedString("IMAGE_COMMENT_TITLE", tableName: "ImageComment", bundle: Bundle(for: ImageCommentViewController.self), comment: "Title for the image comment view")
		
		refreshControl = UIRefreshControl()
		refreshControl?.beginRefreshing()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		
		load()
		errorView?.isHidden = true
	}
	
	@objc func load() {
		loadCommentTask = loader?.load(completion: { [weak self] result in
			switch result {
			
				case .failure(_):
					self?.errorView?.isHidden = false
					
				case .success(let imageComments):
					self?.tableModel = imageComments
					self?.tableView.reloadData()
			}
			
			self?.refreshControl?.endRefreshing()
		})
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellModel = tableModel[indexPath.row]
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		cell.nameLabel.text = cellModel.author.username
		cell.datePostedLabel.text = cellModel.createdAt.relativeDate()
		cell.commentLabel.text = cellModel.message
		return cell
	}
}

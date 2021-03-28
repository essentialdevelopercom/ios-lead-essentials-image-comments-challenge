//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

class ImageCommentCell: UITableViewCell {
	@IBOutlet var usernameLabel: UILabel?
	@IBOutlet var createdAtLabel: UILabel?
	@IBOutlet var commentLabel: UILabel?
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsView, ImageCommentsErrorView {
	
	@IBOutlet private(set) public var errorView: ErrorView?
	
	var models = [PresentableImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	public func display(_ viewModel: ImageCommentsViewModel) {
		models = viewModel.comments
	}
	
	public func display(_ viewModel: ImageCommentsErrorViewModel) {
		errorView?.message = viewModel.message
	}
	
	override public func numberOfSections(in _: UITableView) -> Int {
		return 1
	}
	
	override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		return models.count
	}
	
	override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCommentCell") as! ImageCommentCell
		let model = models[indexPath.row]
		cell.usernameLabel?.text = model.author
		cell.createdAtLabel?.text = model.createdAt
		cell.commentLabel?.text = model.message
		return cell
	}
}

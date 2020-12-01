//
//  ImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Rakesh Ramamurthy on 01/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

class ImageCommentCell: UITableViewCell {
	@IBOutlet var usernameLabel: UILabel?
	@IBOutlet var createdAtLabel: UILabel?
	@IBOutlet var commentLabel: UILabel?
}

public final class ImageCommentsViewController: UITableViewController, ImageCommentsView {
	
	var models = [PresentableImageComment]() {
		didSet {
			tableView.reloadData()
		}
	}

	public func display(_ viewModel: ImageCommentsViewModel) {
		models = viewModel.comments
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
		cell.usernameLabel?.text = model.username
		cell.createdAtLabel?.text = model.createdAt
		cell.commentLabel?.text = model.message
		return cell
	}
}

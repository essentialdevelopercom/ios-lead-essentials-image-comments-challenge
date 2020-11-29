//
//  FeedImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Maxim Soldatov on 11/29/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final public class FeedImageCommentsViewController: UITableViewController, FeedImageCommentsView {
	
	var models = [FeedImageCommentPresentingModel]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		return models.count
	}
	
	override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCommentCell") as! FeedImageCommentCell
		let model = models[indexPath.row]
		cell.display(model)
		
		return cell
	}
	
	public func display(_ viewModel: FeedImageCommentsViewModel) {
		models = viewModel.comments
	}
}

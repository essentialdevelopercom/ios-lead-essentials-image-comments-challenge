//
//  FeedImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Maxim Soldatov on 11/29/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final public class FeedImageCommentsViewController: UITableViewController {
	
	@IBOutlet private(set) public var errorView: ErrorView?
	
	var models = [FeedImageCommentPresentingModel]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
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
	

}

extension FeedImageCommentsViewController: FeedImageCommentsView {
	public func display(_ viewModel: FeedImageCommentsViewModel) {
		models = viewModel.comments
	}
}

extension FeedImageCommentsViewController: FeedImageCommentsErrorView {
	public func display(_ viewModel: FeedImageCommentErrorViewModel) {
		errorView?.message = viewModel.message
	}
}

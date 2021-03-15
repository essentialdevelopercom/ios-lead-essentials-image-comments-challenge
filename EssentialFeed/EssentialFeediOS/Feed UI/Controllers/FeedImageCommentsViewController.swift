//
//  FeedImageCommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Ivan Ornes on 15/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public class FeedImageCommentsViewController: UITableViewController {
	
	private var tableModel = [FeedImageCommentCellController]() {
		didSet { tableView.reloadData() }
	}
	
	public func display(_ cellControllers: [FeedImageCommentCellController]) {
		tableModel = cellControllers
	}
}

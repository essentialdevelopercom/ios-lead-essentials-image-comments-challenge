//
//  CommentsViewController.swift
//  EssentialFeediOS
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol CommentsViewControllerDelegate {
	func didRequestCommentsRefresh()
}

public class CommentsViewController: UITableViewController, CommentView, CommentLoadingView, CommentErrorView {
	
	@IBOutlet private(set) public var errorView: ErrorView!
	
	public var delegate: CommentsViewControllerDelegate?
	public override func viewDidLoad() {
        super.viewDidLoad()
		
    }

    // MARK: - Table view data source

	public override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

	public func display(_ viewModel: CommentViewModel) {
		
	}
	
	public func display(_ viewModel: CommentLoadingViewModel) {
		
	}
	
	public func display(_ viewModel: CommentErrorViewModel) {
		
	}
}

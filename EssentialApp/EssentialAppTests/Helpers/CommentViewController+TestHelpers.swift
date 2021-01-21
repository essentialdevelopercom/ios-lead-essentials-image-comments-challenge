//
//  CommentViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Khoi Nguyen on 7/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeediOS
import UIKit

extension CommentViewController {
	func simulateUserInititateCommentReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	func simulateUserTapOnErrorView() {
		self.errorView?.button.simulateTap()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	func numberOfRenderedComments() -> Int {
		return tableView.numberOfRows(inSection: commentSection)
	}
	
	func commentView(at row: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: commentSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	func commentMessage(at row: Int) -> String? {
		let commentCell = commentView(at: row) as! CommentCell
		return commentCell.messageText
	}
	
	var isShowingErrorView: Bool {
		return errorView?.message != nil
	}
	
	private var commentSection: Int {
		return 0
	}
}

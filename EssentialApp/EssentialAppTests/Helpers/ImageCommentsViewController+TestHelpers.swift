//
//  ImageCommentsViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Ángel Vázquez on 28/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeediOS
import UIKit

extension ImageCommentsViewController {
	private var commentsSection: Int {
		0
	}
	
	private var errorView: CommentErrorView? {
		tableView.tableHeaderView as? CommentErrorView
	}
	
	var errorMessage: String? {
		return errorView?.message
	}
	
	var isShowingLoadingSpinner: Bool {
		refreshControl?.isRefreshing == true
	}
	
	func simulateUserInitiatedReloading() {
		refreshControl?.simulatePullToRefresh()
	}
	
	func simulateTapOnErrorMessage() {
		errorView?.button?.simulateTap()
	}
	
	func numberOfRenderedComments() -> Int {
		tableView.numberOfRows(inSection: commentsSection)
	}
	
	func imageCommentView(at row: Int) -> UITableViewCell? {
		let dataSource = tableView.dataSource
		let indexPath = IndexPath(row: row, section: commentsSection)
		return dataSource?.tableView(tableView, cellForRowAt: indexPath)
	}
}

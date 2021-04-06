//
//  CommentsViewControllers+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS
import EssentialApp
@testable import EssentialApp

extension CommentsViewController {
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}

	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}

	private var commentSection: Int {
		return 0
	}

	func numberOfRenderedCommentViews() -> Int {
		tableView.numberOfRows(inSection: commentSection)
	}

	func commentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: commentSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}

	func commentMessage(at row: Int) -> String? {
		guard let cell = commentView(at: row) as? CommentCell else {
			return nil
		}
		return cell.messageText
	}

	var errorMessage: String? {
		errorView?.message
	}
}


extension CommentCell {
	var usernameText: String? {
		usernameLabel.text
	}

	var messageText: String? {
		messageLabel.text
	}

	var dateText: String? {
		dateLabel.text
	}
}

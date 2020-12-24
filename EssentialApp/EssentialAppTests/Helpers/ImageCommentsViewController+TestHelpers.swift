//
//  ImageCommentsViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Cronay on 24.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension ImageCommentsViewController {
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

	var errorMessage: String? {
		errorView?.message
	}
}

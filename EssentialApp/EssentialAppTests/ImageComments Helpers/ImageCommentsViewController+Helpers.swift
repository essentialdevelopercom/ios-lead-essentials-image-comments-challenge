//
//  ImageCommentsViewController+Helpers.swift
//  EssentialAppTests
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension ImageCommentsViewController {
	var isShowingLoadingIndicator: Bool {
		refreshControl?.isRefreshing ?? false
	}
	
	var errorMessage: String? {
		errorView?.message
	}
	
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	func numberOfRenderedImageCommentsViews() -> Int {
		tableView.numberOfRows(inSection: commentsSectionIndex)
	}
	
	private var commentsSectionIndex: Int { 0 }
	
	func imageCommentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedImageCommentsViews() > row else {
			return nil
		}
		
		let dataSource = tableView.dataSource
		let index = IndexPath(row: row, section: commentsSectionIndex)
		return dataSource?.tableView(tableView, cellForRowAt: index)
	}
}


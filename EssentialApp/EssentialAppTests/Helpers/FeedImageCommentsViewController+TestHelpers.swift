//
//  FeedImageCommentsViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Ivan Ornes on 27/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedImageCommentsViewController {
	func simulateUserInitiatedFeedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	var errorMessage: String? {
		return errorView?.message
	}
	
	func numberOfRenderedFeedImageCommentViews() -> Int {
		return tableView.numberOfRows(inSection: feedImageCommentsSection)
	}
	
	func feedImageCommentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedFeedImageCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedImageCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	private var feedImageCommentsSection: Int {
		return 0
	}
}

//
//  FeedImageCommentViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Mario Alberto Barragán Espinosa on 11/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedImageCommentViewController {
	func simulateUserInitiatedFeedCommentReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	func numberOfRenderedFeedImageCommentsViews() -> Int {
		return tableView.numberOfRows(inSection: feedCommentsSection)
	}
	
	func feedImageCommentView(at row: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	private var feedCommentsSection: Int {
		return 0
	}
}

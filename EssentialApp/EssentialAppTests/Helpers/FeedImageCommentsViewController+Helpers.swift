//
//  FeedImageCommentsViewController+Helpers.swift
//  EssentialAppTests
//
//  Created by Maxim Soldatov on 12/1/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import UIKit
import EssentialFeediOS

extension FeedImageCommentsViewController {
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	var errorMessage: String? {
		return errorView?.message
	}
	
	@discardableResult
	func simulateFeedCommentViewVisible(at index: Int) -> FeedImageCommentCell? {
		return feedCommentView(at: index) as? FeedImageCommentCell
	}
	
	func simulateUserInitiatedCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	func feedCommentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedFeedCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	func numberOfRenderedFeedCommentViews() -> Int {
		return tableView.numberOfRows(inSection: feedCommentsSection)
	}
	
	private var feedCommentsSection: Int {
		return 0
	}
}

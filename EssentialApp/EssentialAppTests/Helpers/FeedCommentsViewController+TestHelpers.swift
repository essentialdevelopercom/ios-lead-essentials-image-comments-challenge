//
//  Created by Azamat Valitov on 04.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedCommentsViewController {
	func simulateUserInitiatedFeedCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	func numberOfRenderedFeedCommentViews() -> Int {
		return tableView.numberOfRows(inSection: feedCommentsSection)
	}
	
	private var feedCommentsSection: Int {
		return 0
	}
	
	func feedCommentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedFeedCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	var errorMessage: String? {
		return errorView?.message
	}
	
	@discardableResult
	func simulateFeedImageViewVisible(at index: Int) -> FeedCommentCell? {
		return commentView(at: index)
	}
	
	func commentView(at row: Int) -> FeedCommentCell? {
		guard numberOfRenderedFeedCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index) as? FeedCommentCell
	}
}

extension FeedCommentsViewController {
	func commentMessage(at row: Int) -> String? {
		commentView(at: row)?.messageLabel.text
	}
	
	func commentDate(at row: Int) -> String? {
		commentView(at: row)?.dateLabel.text
	}
	
	func commentUsername(at row: Int) -> String? {
		commentView(at: row)?.authorNameLabel.text
	}
}

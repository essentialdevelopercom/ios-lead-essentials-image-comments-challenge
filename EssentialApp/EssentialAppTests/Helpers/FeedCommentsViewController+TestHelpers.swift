//
//  FeedCommentsViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Danil Vassyakin on 4/20/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
@testable import EssentialFeediOS

extension FeedCommentsViewController {
	
	private var imageCommentsSection: Int { 0 }
	
	func simulateTapOnErrorView() {
		errorView.gestureRecognizers?.forEach { $0.state = .ended }
	}
	
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	func numberOfRenderedFeedCommentViews() -> Int {
		tableView.numberOfRows(inSection: imageCommentsSection)
	}
	
	func commentView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedFeedCommentViews() > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: imageCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	var errorMessage: String? {
		errorView?.message
	}

	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
}

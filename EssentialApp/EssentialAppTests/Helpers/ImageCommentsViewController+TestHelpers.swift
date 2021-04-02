//
//  ImageCommentsViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Bogdan Poplauschi on 02/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension ImageCommentsViewController {
	func simulateUserInitiatedImageCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	func numberOfRenderedImageComments() -> Int {
		tableView.numberOfRows(inSection: imageCommentsSection)
	}
	
	func imageCommentView(at row: Int) -> UITableViewCell? {
		let indexPath = IndexPath(row: row, section: imageCommentsSection)
		let ds = tableView.dataSource
		return ds?.tableView(tableView, cellForRowAt: indexPath)
	}
	
	var errorMessage: String? {
		errorView?.message
	}
	
	var imageCommentsSection: Int { 0 }
}

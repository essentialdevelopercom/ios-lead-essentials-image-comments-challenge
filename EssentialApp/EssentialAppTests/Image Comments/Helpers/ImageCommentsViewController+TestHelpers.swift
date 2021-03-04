//
//  ImageCommentsViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Alok Subedi on 06/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeediOS
import UIKit

extension ImageCommentsViewController {
	var errorMessage: String? {
		return errorView?.message
	}
	
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	func renderedCell(at row: Int) -> ImageCommentsCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: imageCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentsCell
	}
	
	var isShowingLoadingIndicator: Bool {
		return self.refreshControl?.isRefreshing == true
	}
	
	var numberOfRenderedImageCommentsViews: Int {
		return tableView.numberOfRows(inSection: imageCommentsSection)
	}
	
	func commentMessage(at row: Int) -> String? {
		let cell = renderedCell(at: row)
		return cell?.message.text
	}
	
	private var imageCommentsSection: Int { 0 }
}

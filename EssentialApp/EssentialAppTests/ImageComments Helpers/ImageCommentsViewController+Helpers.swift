//
//  ImageCommentsViewController+Helpers.swift
//  EssentialAppTests
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
@testable import EssentialFeediOS

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
	
	func simulateUserTapOnTheErrorMessage() {
		dismissErrorView()
	}
	
	func numberOfRenderedImageCommentsViews() -> Int {
		tableView.numberOfRows(inSection: commentsSectionIndex)
	}
	
	func renderedImageCommentMessage(at index: Int) -> String? {
		simulateImageCommentViewVisible(at: index)?.messageLabel.text
	}
	
	@discardableResult
	func simulateImageCommentViewVisible(at index: Int) -> ImageCommentCell? {
		imageCommentView(at: index) as? ImageCommentCell
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


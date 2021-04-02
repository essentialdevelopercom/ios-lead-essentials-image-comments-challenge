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
		numberOfRows(in: imageCommentsSection)
	}
	
	func imageCommentView(at row: Int) -> ImageCommentCell? {
		guard row < numberOfRows(in: imageCommentsSection) else { return nil }
		
		let indexPath = IndexPath(row: row, section: imageCommentsSection)
		let ds = tableView.dataSource
		return ds?.tableView(tableView, cellForRowAt: indexPath) as? ImageCommentCell
	}
	
	func imageCommentMessage(at row: Int) -> String? {
		return imageCommentView(at: row)?.commentText
	}
	
	var errorMessage: String? {
		errorView?.message
	}
	
	private var imageCommentsSection: Int { 0 }
	
	private func numberOfRows(in section: Int) -> Int {
		section < tableView.numberOfSections ? tableView.numberOfRows(inSection: section) : 0
	}
}

//
//  ImageCommentsViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Sebastian Vidrea on 04.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension ImageCommentsViewController {
	var isShowingLoadingIndicator: Bool {
		refreshControl?.isRefreshing == true
	}

	private var imageCommentsSection: Int {
		return 0
	}

	func simulateUserInitiatedImageCommentsReload() {
		refreshControl?.simulatePullToRefresh()
	}

	func numberOfRenderedImageCommentViews() -> Int {
		tableView.numberOfRows(inSection: imageCommentsSection)
	}

	var errorMessage: String? {
		errorView?.message
	}

	@discardableResult
	func simulateImageCommentViewVisible(at index: Int) -> ImageCommentCell? {
		imageCommentView(at: index) as? ImageCommentCell
	}

	@discardableResult
	func simulateImageCommentNotVisible(at row: Int) -> ImageCommentCell? {
		let view = simulateImageCommentViewVisible(at: row)

		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: imageCommentsSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

		return view
	}

	func imageCommentView(at row: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: imageCommentsSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
}

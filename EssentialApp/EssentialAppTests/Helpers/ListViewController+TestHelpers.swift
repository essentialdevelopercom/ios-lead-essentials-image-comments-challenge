//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

// MARK: General

extension ListViewController {
	public override func loadViewIfNeeded() {
		super.loadViewIfNeeded()

		tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
	}

	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}

	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}

	func simulateErrorViewTap() {
		errorView.simulateTap()
	}

	var errorMessage: String? {
		return errorView.message
	}

	func numberOfRows(in section: Int) -> Int {
		tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
	}

	func cell(row: Int, section: Int) -> UITableViewCell? {
		guard numberOfRows(in: section) > row else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: section)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
}

// MARK: Feed

extension ListViewController {
	@discardableResult
	func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
		return feedImageView(at: index) as? FeedImageCell
	}

	@discardableResult
	func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
		let view = simulateFeedImageViewVisible(at: row)

		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: feedImagesSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

		return view
	}

	func simulateTapOnFeedImage(at row: Int) {
		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: feedImagesSection)
		delegate?.tableView?(tableView, didSelectRowAt: index)
	}

	func simulateFeedImageViewNearVisible(at row: Int) {
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedImagesSection)
		ds?.tableView(tableView, prefetchRowsAt: [index])
	}

	func simulateFeedImageViewNotNearVisible(at row: Int) {
		simulateFeedImageViewNearVisible(at: row)

		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedImagesSection)
		ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
	}

	func renderedFeedImageData(at index: Int) -> Data? {
		return simulateFeedImageViewVisible(at: index)?.renderedImage
	}

	func numberOfRenderedFeedImageViews() -> Int {
		numberOfRows(in: feedImagesSection)
	}

	func feedImageView(at row: Int) -> UITableViewCell? {
		cell(row: row, section: feedImagesSection)
	}

	private var feedImagesSection: Int { 0 }
}

// MARK: ImageComments

extension ListViewController {
	func numberOfRenderedImageCommentsViews() -> Int {
		numberOfRows(in: imageCommentsSection)
	}

	func imageCommentView(at row: Int) -> UITableViewCell? {
		cell(row: row, section: imageCommentsSection)
	}

	func firstCommentMessage() -> String? {
		(imageCommentView(at: 0) as? ImageCommentCell)?.messageText
	}

	private var imageCommentsSection: Int { 0 }
}

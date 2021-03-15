//
//  FeedImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Ivan Ornes on 15/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class FeedImageCommentsSnapshotTests: XCTestCase {
	
	func test_emptyFeedImageComments() {
		let sut = makeSUT()
		
		sut.display(emptyFeedImageComments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENTS_FEED_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENTS_FEED_dark")
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> FeedImageCommentsViewController {
		let bundle = Bundle(for: FeedImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "FeedImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! FeedImageCommentsViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyFeedImageComments() -> [FeedImageCommentCellController] {
		return []
	}
}

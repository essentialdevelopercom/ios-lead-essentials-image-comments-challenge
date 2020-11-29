//
//  FeedImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Maxim Soldatov on 11/29/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedImageCommentsSnapshotTests: XCTestCase {

	func test_emptyFeed() {
		let sut = makeSUT()
		
		sut.display(FeedImageCommentsViewModel(comments: []))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_EMPTY_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_EMPTY_COMMENTS_dark")
	}
	// MARK: -Helpers
	
	private func makeSUT() -> FeedImageCommentsViewController {
		let bundle = Bundle(for: FeedImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "FeedImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! FeedImageCommentsViewController
		
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}

}

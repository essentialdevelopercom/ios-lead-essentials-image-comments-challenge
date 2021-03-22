//
//  CommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Anton Ilinykh on 22.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS

class CommentsSnapshotTests: XCTestCase {

	func test_emptyCommetns() {
		let sut = makeSUT()
		
		sut.display(emptyComments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_COMMENTS_dark")
	}

	// MARK: - Helpers
	
	private func makeSUT() -> CommentsController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let controller = storyboard.instantiateViewController(identifier: "CommentsController") as! CommentsController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyComments() -> [CommentCellController] {
		return []
	}
}

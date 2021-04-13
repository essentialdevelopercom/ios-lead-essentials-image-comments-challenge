//
//  ImageCommentSnapshotTest.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Mayorga on 4/13/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentSnapshotTests: XCTestCase {
	
	func test_emptyFeedImageComments() {
		let sut = makeSUT()
		
		sut.display(emptyFeedImageComments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENTS_FEED_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENTS_FEED_dark")
	}
	
	func test_feedImageWithComments() {
		let sut = makeSUT()
		
		sut.display(comments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_IMAGE_WITH_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_IMAGE_WITH_COMMENTS_dark")
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> ImageCommentViewController {
		let bundle = Bundle(for: ImageCommentViewController.self)
		let storyboard = UIStoryboard(name: "ImageComment", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ImageCommentViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyFeedImageComments() -> [ImageCommentStub] {
		return []
	}
	
	private func comments() -> [ImageCommentStub] {
		return [
			ImageCommentStub(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
							 creationDate: "2019-01-10T18:12:10+0000",
							 author: "Be"),
			ImageCommentStub(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
							 creationDate: "2020-05-20T11:24:59+0000",
							 author: "Brian"),
			ImageCommentStub(message: "💯",
							 creationDate: "2021-04-12T12:21:57+0000",
							 author: "Tim"),
			ImageCommentStub(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 🐵\n.\n.\n.\n🐯 Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
							 creationDate: "2021-04-13T11:24:59+0000",
							 author: "Jim")
		]
	}
}

extension ImageCommentViewController {
	fileprivate func display(_ stubs: [ImageCommentStub]) {
		var commentModel: [ImageComment] = []
		stubs.forEach { commentModel.append($0.viewModel) }
		tableModel = commentModel
		tableView.reloadData()
		refreshControl?.endRefreshing()
	}
}

private class ImageCommentStub {
	let viewModel: ImageComment
	
	init(message: String, creationDate: String, author: String) {
		viewModel = .init(id: UUID(),
						  message: message,
						  createdAt: ISO8601DateFormatter().date(from: creationDate)!,
						  author: ImageCommentAuthor.init(username: author))
	}
}

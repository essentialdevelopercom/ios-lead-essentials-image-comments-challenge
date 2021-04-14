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
	
	func test_feedImageWithCommentsWithExtraExtraExtraLargeContentSize() {
		let sut = makeSUT()
		
		sut.display(comments())
		
		let lightConfiguration: SnapshotConfiguration = .iPhone8(style: .light,
																 contentSizeCategory: .extraExtraExtraLarge)
		let darkConfiguration: SnapshotConfiguration = .iPhone8(style: .dark,
																contentSizeCategory: .extraExtraExtraLarge)
		
		assert(snapshot: sut.snapshot(for: lightConfiguration), named: "FEED_IMAGE_WITH_ExtraExtraLarge_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: darkConfiguration), named: "FEED_IMAGE_WITH_ExtraExtraLarge_COMMENTS_dark")
	}
	
	func test_feedImageCommentWithErrorMessage() {
		let sut = makeSUT()
		
		sut.displayError(message: "This is a\nmulti-line\nerror message")
				
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_IMAGE_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_IMAGE_WITH_ERROR_MESSAGE_dark")
	}
	
	func test_feedImageCommentWithErrorMessageWithExtraExtraExtraLargeContentSize() {
		let sut = makeSUT()
		
		sut.displayError(message: "This is a\nmulti-line\nerror message")
		
		let lightConfiguration: SnapshotConfiguration = .iPhone8(style: .light,
																 contentSizeCategory: .extraExtraExtraLarge)
		let darkConfiguration: SnapshotConfiguration = .iPhone8(style: .dark,
																contentSizeCategory: .extraExtraExtraLarge)
		
		assert(snapshot: sut.snapshot(for: lightConfiguration), named: "FEED_IMAGE_WITH_ExtraExtraLarge_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: darkConfiguration), named: "FEED_IMAGE_WITH_ExtraExtraLarge_ERROR_MESSAGE_dark")
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
							 creationDate: "2 years ago",
							 author: "Be"),
			ImageCommentStub(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
							 creationDate: "10 months ago",
							 author: "Brian"),
			ImageCommentStub(message: "💯",
							 creationDate: "1 day ago",
							 author: "Tim"),
			ImageCommentStub(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 🐵\n.\n.\n.\n🐯 Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
							 creationDate: "9 hours ago",
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
	
	fileprivate func displayError(message: String) {
		errorView?.isHidden = false
		errorViewLabel.text = message
		refreshControl?.endRefreshing()
	}
}

private class ImageCommentStub {
	let viewModel: ImageComment
	
	init(message: String, creationDate: String, author: String) {
		viewModel = .init(id: UUID(),
						  message: message,
						  createdAt: creationDate,
						  author: ImageCommentAuthor.init(username: author))
	}
}

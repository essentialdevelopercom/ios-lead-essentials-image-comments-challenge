//
//  FeedCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Danil Vassyakin on 4/19/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeed
import EssentialFeediOS

class FeedCommentsSnapshotTests: XCTestCase {

	func test_emptyComments() {
		let sut = makeSUT()

		sut.display(noComments())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_IMAGE_COMMENTS_EMPTY_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_IMAGE_COMMENTS_EMPTY_dark")
	}

	func test_commentsWithErrorMessage() {
		let sut = makeSUT()

		sut.display(errorMessage("This is\na multi-line\nerror message"))
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_IMAGE_COMMENTS_ERROR_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_IMAGE_COMMENTS_ERROR_dark")
	}

	func test_commentsWithContent() {
		let sut = makeSUT()

		sut.display(comments())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_IMAGE_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_IMAGE_COMMENTS_dark")
	}

	// MARK: - Helpers

	private func makeSUT() -> FeedCommentsViewController {
		let bundle = Bundle(for: FeedCommentsViewController.self)
		let storyboard = UIStoryboard(name: "FeedComments", bundle: bundle)
		let vc = storyboard.instantiateViewController(identifier: "feedComments") as! FeedCommentsViewController
		vc.loadViewIfNeeded()
		vc.tableView.showsVerticalScrollIndicator = false
		vc.tableView.showsHorizontalScrollIndicator = false
		return vc
	}

	private func noComments() -> FeedImageCommentViewModel {
		.init(comments: [])
	}

	private func errorMessage(_ message: String) -> FeedImageCommentErrorViewModel {
		.error(message: message)
	}

	private func comments() -> FeedImageCommentViewModel {
		let comment0 = PresentationImageComment(message: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr.", createdAt: "1 year ago", author: "danil")
		let comment1 = PresentationImageComment(message: "Lorem ipsum!\n.\n.\n.\n.", createdAt: "6 month ago", author: "danil")
		let comment2 = PresentationImageComment(message: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.", createdAt: "1 day ago", author: "danil")
		let comment3 = PresentationImageComment(message: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.", createdAt: "Just now", author: "danil")
		return .init(comments: [comment0, comment1, comment2, comment3])
	}
	
}

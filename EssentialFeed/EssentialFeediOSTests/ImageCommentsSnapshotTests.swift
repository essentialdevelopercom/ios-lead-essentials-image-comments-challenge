//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Cronay on 23.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
@testable import EssentialFeed
import EssentialFeediOS

class ImageCommentsSnapshotTests: XCTestCase {

	func test_emptyComments() {
		let sut = makeSUT()

		sut.display(ImageCommentsViewModel(presentables: []))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENTS_dark")
	}

	func test_commentsWithErrorMessage() {
		let sut = makeSUT()

		sut.display(ImageCommentsErrorViewModel(message: "This is\na multi-line\nerror message"))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "COMMENTS_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "COMMENTS_WITH_ERROR_MESSAGE_dark")
	}

	// MARK: - Helpers

	private func makeSUT() -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
}

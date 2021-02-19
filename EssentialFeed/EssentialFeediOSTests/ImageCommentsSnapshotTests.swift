//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Raphael Silva on 19/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

@testable import EssentialFeed
import EssentialFeediOS
import XCTest

class ImageCommentsSnapshotTests: XCTestCase {

	func test_emptyComments() {
		let sut = makeSUT()

		sut.display(emptyComments())

		assert(
			snapshot: sut.snapshot(for: .iPhone8(style: .light)),
			named: "IMAGE_COMMENTS_EMPTY_COMMENTS_light"
		)
		assert(
			snapshot: sut.snapshot(for: .iPhone8(style: .dark)),
			named: "IMAGE_COMMENTS_EMPTY_COMMENTS_dark"
		)
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

	private func emptyComments() -> ImageCommentsViewModel {
		ImageCommentsViewModel(comments: [])
	}
}

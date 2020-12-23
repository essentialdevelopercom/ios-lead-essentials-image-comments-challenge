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

	func test_commentsWithContent() {
		let sut = makeSUT()

		sut.display(ImageCommentsViewModel(presentables: makeComments()))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "LOADED_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "LOADED_COMMENTS_dark")
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

	private func makeComments() -> [PresentableImageComment] {
		let comment0 = PresentableImageComment(username: "Some User", message: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr.", date: "1 year ago")
		let comment1 = PresentableImageComment(username: "A very long long long username", message: "Lorem ipsum!\n.\n.\n.\n.", date: "6 month ago")
		let comment2 = PresentableImageComment(username: "Another User", message: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.", date: "1 day ago")
		let comment3 = PresentableImageComment(username: "Last User", message: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.", date: "Just now")
		return [comment0, comment1, comment2, comment3]
	}
}

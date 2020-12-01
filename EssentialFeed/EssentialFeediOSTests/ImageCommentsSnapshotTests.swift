//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Rakesh Ramamurthy on 01/12/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

@testable import EssentialFeed
import EssentialFeediOS
import XCTest

final class ImageCommentsSnapshotTests: XCTestCase {
	
	func test_emptyComments() {
		let sut = makeSUT()

		sut.display(noComments())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_EMPTY_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_EMPTY_COMMENTS_dark")
	}

	func test_imageWithComments() {
		let sut = makeSUT()

		sut.display(imageComments())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_COMMENTS_dark")
	}

	func test_imageCommentsWithError() {
		let sut = makeSUT()

		sut.display(ImageCommentsErrorViewModel(errorMessage: "This is a\nmulti-line\nerror message"))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_ERROR_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_ERROR_dark")
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

	private func noComments() -> ImageCommentsViewModel {
		ImageCommentsViewModel(comments: [])
	}
	
	private func imageComments() -> ImageCommentsViewModel {
		let comment1 = PresentableImageComment(
			username: "Diego Jota",
			createdAt: "2 weeks ago",
			message: "In nature, light creates the color. In the picture, color creates the light."
		)
		let comment2 = PresentableImageComment(
			username: "Rakesh R",
			createdAt: "3 months ago",
			message: "The power of beauty lies within the soul. This picture is worth a thousand words."
		)
		let comment3 = PresentableImageComment(
			username: "Cristiano Ronaldo",
			createdAt: "2 hours ago",
			message: "Beauty is power; a smile is its sword."
		)
		let comment4 = PresentableImageComment(
			username: "Steven Gerrard",
			createdAt: "3 years ago",
			message: "Man oh man, if I didn't look a second time I wouldn't believe someone as beautiful as you existed."
		)
		return ImageCommentsViewModel(comments: [comment1, comment2, comment3, comment4])
	}
}

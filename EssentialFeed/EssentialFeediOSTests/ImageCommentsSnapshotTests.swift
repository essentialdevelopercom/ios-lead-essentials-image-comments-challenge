//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Sebastian Vidrea on 06.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
	func test_emptyImageComments() {
		let sut = makeSUT()

		sut.display(emptyImageComments())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENTS_dark")
	}

	func test_emptyImageCommentsWithContent() {
		let sut = makeSUT()

		sut.display(imageCommentsWithContent())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_CONTENT_dark")
	}

	func test_imageCommentsWithErrorMessage() {
		let sut = makeSUT()

		sut.display(.error(message: "This is a\nmulti-line\nerror message"))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_dark")
	}

	func test_imageCommentsLoading() {
		let sut = makeSUT()

		sut.display(.init(isLoading: true))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_LOADING_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_LOADING_dark")
	}

	func test_imageCommentsWithDynamicFonts() {
		let sut = makeSUT()

		sut.display(imageCommentsWithContent())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_DYNAMIC_FONTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_DYNAMIC_FONTS_dark")
	}

	// MARK: - Helpers

	private func makeSUT() -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		controller.loadViewIfNeeded()
		return controller
	}

	private func emptyImageComments() -> [ImageCommentCellController] {
		return []
	}

	private func imageCommentsWithContent() -> [ImageCommentStub] {
		[
			ImageCommentStub(
				message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur dignissim volutpat condimentum. Nam elementum tincidunt ligula, vitae auctor arcu pulvinar sed",
				author: "Author",
				createdAt: "Today"
			),
			ImageCommentStub(
				message: "Message",
				author: "Another author",
				createdAt: "One hour ago"
			),
		]
	}
}

private extension ImageCommentsViewController {
	func display(_ stubs: [ImageCommentStub]) {
		let cells: [ImageCommentCellController] = stubs.map { stub in
			let cellController = ImageCommentCellController(delegate: stub)
			stub.controller = cellController
			return cellController
		}

		display(cells)
	}
}

private class ImageCommentStub: ImageCommentCellControllerDelegate {
	let viewModel: ImageCommentViewModel
	weak var controller: ImageCommentCellController?

	init(message: String?, author: String?, createdAt: String?) {
		viewModel = ImageCommentViewModel(
			message: message,
			author: author,
			createdAt: createdAt
		)
	}

	func didLoadCell() {
		controller?.display(viewModel)
	}

	func willReleaseCell() {}
}

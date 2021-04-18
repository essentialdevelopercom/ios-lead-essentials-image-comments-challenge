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
	func test_imageCommentsWithContent() {
		let sut = makeSUT()

		sut.display(comments())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_CONTENT_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_WITH_CONTENT_light_extraExtraExtraLarge")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_WITH_CONTENT_dark_extraExtraExtraLarge")
	}

	// MARK: - Helpers

	private func makeSUT() -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ListViewController
		controller.loadViewIfNeeded()
		return controller
	}

	private func comments() -> [CellController] {
		imageComments().map { CellController(id: UUID(), $0) }
	}

	private func imageComments() -> [ImageCommentCellController] {
		[
			ImageCommentCellController(
				viewModel: ImageCommentViewModel(
					message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur dignissim volutpat condimentum. Nam elementum tincidunt ligula, vitae auctor arcu pulvinar sed",
					username: "Username",
					createdAt: "Today"
				)
			),
			ImageCommentCellController(
				viewModel: ImageCommentViewModel(
					message: "Message",
					username: "Another username",
					createdAt: "One hour ago"
				)
			)
		]
	}
}

//private extension ListViewController {
//	func display(_ stubs: [ImageCommentStub]) {
//		let cells: [CellController] = stubs.map { stub in
//			let cellController = ImageCommentCellController(viewModel: stub.viewModel, delegate: stub)
//			stub.controller = cellController
//			return cellController
//		}
//
//		display(cells)
//	}
//}
//
//private class ImageCommentStub: ImageCommentCellControllerDelegate {
//	let viewModel: ImageCommentViewModel
//	weak var controller: ImageCommentCellController?
//
//	init(message: String?, username: String?, createdAt: String?) {
//		viewModel = ImageCommentViewModel(
//			message: message,
//			username: username,
//			createdAt: createdAt
//		)
//	}
//
//	func didLoadCell() {
//		controller?.display(ResourceLoadingViewModel(isLoading: false))
//		controller?.display(ResourceErrorViewModel(message: .none))
//		controller?.display(viewModel)
//	}
//
//	func willReleaseCell() {}
//}

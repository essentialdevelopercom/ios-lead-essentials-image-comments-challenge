//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Ángel Vázquez on 28/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

@testable import EssentialFeed
import EssentialFeediOS
import XCTest

class ImageCommentsSnapshotTests: XCTestCase {
	func test_emptyCommentsList() {
		let sut = makeSUT()
		
		sut.display(emptyFeed())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENTS_dark")
	}
	
	func test_commentsListWithContent() {
		let sut = makeSUT()
		
		sut.display(commentsListWithContent())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_CONTENT_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_WITH_CONTENT_extraExtraExtraLarge")
	}
	
	func test_commentsListWithErrorMessage() {
		let sut = makeSUT()
		
		sut.refreshController?.display(ImageCommentsErrorViewModel(message: "This is a\nmulti-line\nerror message"))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_extraExtraExtraLarge")
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
	
	private func emptyFeed() -> [ImageCommentsCellController] {
		return []
	}
	
	private func commentsListWithContent() -> [ImageCommentViewModel] {
		return [
			ImageCommentViewModel(
				author: "Joe",
				message: "The gallery was seen in Wolfgang Becker's movie Goodbye, Lenin!",
				creationDate: "8 months ago"
			),
			ImageCommentViewModel(
				author: "Megan",
				message: "It was also featured in English indie/rock band Bloc Party's single Kreuzberg taken from the album A Weekend in the City.",
				creationDate: "3 days ago"
			),
			ImageCommentViewModel(
				author: "Dwight",
				message: "The restoration process has been marked by major conflict. Eight of the artists of 1990 refused to paint their own images again after they were completely destroyed by the renovation. In order to defend the copyright, they founded Founder Initiative East Side with other artists whose images were copied without permission.",
				creationDate: "12 hours ago"
			)
		]
	}
}

private extension ImageCommentsViewController {
	func display(_ viewModels: [ImageCommentViewModel]) {
		let cells: [ImageCommentsCellController] = viewModels.map { viewModel in
			ImageCommentsCellController(viewModel: viewModel)
		}
		display(cells)
	}
}

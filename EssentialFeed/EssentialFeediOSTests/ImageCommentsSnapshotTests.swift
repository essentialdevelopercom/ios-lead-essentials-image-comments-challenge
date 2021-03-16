//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
	
	func test_emptyList() {
		let sut = makeSUT()
		
		sut.display(emptyList())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENTS_LIGHT")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENTS_DARK")
	}
	
	func test_loadingState() {
		let sut = makeSUT()

		sut.refreshControl?.beginRefreshing()

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_LOADING_LIGHT")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_LOADING_DARK")
	}
	
	func test_commentsWithContent() {
		let sut = makeSUT()
		
		sut.display(commentsWithContent())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_CONTENT_LIGHT")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_CONTENT_DARK")
	}
	
	func test_commentsWithErrorMessage() {
		let sut = makeSUT()
		
		sut.display(ImageCommentsErrorViewModel(message: "This is a\nmulti-line\nerror message"))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_LIGHT")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_DARK")
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> ImageCommentsViewController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyList() -> [ImageCommentCellController] {
		[]
	}
	
	private func commentsWithContent() -> [ImageCommentCellController] {
		[
			ImageCommentCellController(
				viewModel: { ImageCommentViewModel(
					authorUsername: "Ἀριστοτέλης",
					date: Date().addingTimeInterval(-100000),
					body: "But we think that knowledge and the ability to understand belong to knowledge rather than experience, and we believe that people of knowledge are smarter than empiricists, because wisdom depends in all cases on knowledge. And it is because they know the cause and they don't; empiricists know the effect but do not know the cause, and theorists know both the effect and the cause.") },
				relativeDate: { Date() }),
			ImageCommentCellController(
				viewModel: { ImageCommentViewModel(
					authorUsername: "Ἡράκλειτος ὁ Ἐφέσιος",
					date: Date().addingTimeInterval(-10000000),
					body: "μάχεσθαι χρὴ τὸν δῆμον ὑπὲρ τοῦ νόμου ὅκωσπερ τείχεος") },
				relativeDate: { Date() }),
		]
	}
	
}

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

		sut.display(ImageCommentsLoadingViewModel(isLoading: true))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_LOADING_LIGHT")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_LOADING_DARK")
	}
	
	func test_commentsWithContent() {
		let sut = makeSUT()
		
		sut.display(commentsWithContent())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_CONTENT_LIGHT")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_CONTENT_DARK")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraLarge)), named: "IMAGE_COMMENTS_WITH_CONTENT_DARK_EXTRA_EXTRA_LARGE")
	}
	
	func test_commentsWithErrorMessage() {
		let sut = makeSUT()
		
		sut.display(ImageCommentsErrorViewModel(message: "This is a\nmulti-line\nerror message"))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_LIGHT")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_DARK")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraLarge)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_DARK_EXTRA_EXTRA_LARGE")
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
			ImageCommentViewModel(
				authorUsername: "Ἀριστοτέλης",
				createdAt: "1 minuto atrás",
				message: "But we think that knowledge and the ability to understand belong to knowledge rather than experience, and we believe that people of knowledge are smarter than empiricists, because wisdom depends in all cases on knowledge. And it is because they know the cause and they don't; empiricists know the effect but do not know the cause, and theorists know both the effect and the cause."),
			ImageCommentViewModel(
				authorUsername: "Ἡράκλειτος ὁ Ἐφέσιος",
				createdAt: "10 minutos atrás",
				message: "μάχεσθαι χρὴ τὸν δῆμον ὑπὲρ τοῦ νόμου ὅκωσπερ τείχεος"),
			ImageCommentViewModel(
				authorUsername: "This is a username that could exist",
				createdAt: "3 dias atrás",
				message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Dui faucibus in ornare quam viverra orci. Purus semper eget duis at tellus. Eros in cursus turpis massa tincidunt dui ut. Nam at lectus urna duis. Malesuada fames ac turpis egestas integer eget aliquet. Sed enim ut sem viverra aliquet. Commodo nulla facilisi nullam vehicula ipsum. Nisl nunc mi ipsum faucibus. Odio morbi quis commodo odio. Tellus molestie nunc non blandit massa. Condimentum id venenatis a condimentum vitae sapien pellentesque.")
			]
		.map(ImageCommentCellController.init)
	}
	
}

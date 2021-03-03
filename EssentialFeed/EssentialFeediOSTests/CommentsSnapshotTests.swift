//
//  CommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Robert Dates on 2/13/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class CommentsSnapshotTests: XCTestCase {
	func test_emptyComments() {
		let sut = makeSUT()

		sut.display(noComments())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENTS_dark")
	}
	
	func test_commentsWithErrorMessage() {
		let sut = makeSUT()

		sut.display(errorMessage("This is\na multi-line\nerror message"))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "COMMENTS_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "COMMENTS_WITH_ERROR_MESSAGE_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "COMMENTS_WITH_ERROR_MESSAGE_extraExtraExtraLarge_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraExtraLarge)), named: "COMMENTS_WITH_ERROR_MESSAGE_extraExtraExtraLarge_dark")
	}
	
	func test_commentsWithContent() {
		let sut = makeSUT()

		sut.display(comments())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "LOADED_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "LOADED_COMMENTS_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "COMMENTS_WITH_CONTENT_extraExtraExtraLarge_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraExtraLarge)), named: "COMMENTS_WITH_CONTENT_extraExtraExtraLarge_dark")
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> CommentsViewController {
		let bundle = Bundle(for: CommentsViewController.self)
		let storyboard = UIStoryboard(name: "Comments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! CommentsViewController
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		controller.loadViewIfNeeded()
		return controller
	}
	
	private func noComments() -> CommentViewModel {
		return CommentViewModel(comments: [])
	}

	private func errorMessage(_ message: String) -> CommentErrorViewModel {
		return CommentErrorViewModel(message: message)
	}
	
	private func comments() -> CommentViewModel {
		let comment0 = PresentableComment(username: "Some User", message: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr.", date: "1 year ago")
		let comment1 = PresentableComment(username: "A very long long long username", message: "Lorem ipsum!\n.\n.\n.\n.", date: "6 month ago")
		let comment2 = PresentableComment(username: "Another User", message: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.", date: "1 day ago")
		let comment3 = PresentableComment(username: "Last User", message: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.", date: "Just now")
		return CommentViewModel(comments: [comment0, comment1, comment2, comment3])
	}
	
}

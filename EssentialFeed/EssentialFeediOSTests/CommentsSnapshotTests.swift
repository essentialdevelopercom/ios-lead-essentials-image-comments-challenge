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
	
	// MARK: - Helpers
	
	private func makeSUT() -> CommentsViewController {
		let bundle = Bundle(for: CommentsViewController.self)
		let storyboard = UIStoryboard(name: "Comments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! CommentsViewController
		controller.loadViewIfNeeded()
		return controller
	}
	
	private func noComments() -> CommentViewModel {
		return CommentViewModel(comments: [])
	}

	private func errorMessage(_ message: String) -> CommentErrorViewModel {
		return CommentErrorViewModel(message: message)
	}
	
}

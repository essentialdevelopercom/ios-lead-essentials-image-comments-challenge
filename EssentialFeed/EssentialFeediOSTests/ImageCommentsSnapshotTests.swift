//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Bogdan Poplauschi on 28/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import XCTest

final class ImageCommentsSnapshotTests: XCTestCase {
	func test_emptyImageComments() {
		let sut = makeSUT()
		
		sut.display(emptyImageComments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_EMPTY_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_EMPTY_COMMENTS_dark")
	}
	
	func test_imageCommentsWithComments() {
		let sut = makeSUT()
		
		sut.display(imageComments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_COMMENTS_dark")
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
	
	private func emptyImageComments() -> ImageCommentsViewModel {
		ImageCommentsViewModel(comments: [])
	}
	
	private func imageComments() -> ImageCommentsViewModel {
		return ImageCommentsViewModel(comments: [
			PresentableImageComment(
				createdAt: "2 weeks ago",
				message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
				author: "Jen"
			),
			PresentableImageComment(
				createdAt: "1 week ago",
				message: "Lorem ipsum dolor sit amet.",
				author: "Megan"
			),
			PresentableImageComment(
				createdAt: "3 days ago",
				message: "💯",
				author: "Jim"
			),
			PresentableImageComment(
				createdAt: "3 days ago",
				message: "Lorem ipsum dolor sit amet. ☀️\n.\n.\n.\n.\n.\n.\n✅\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
				author: "Brian"
			)
		])
	}
}

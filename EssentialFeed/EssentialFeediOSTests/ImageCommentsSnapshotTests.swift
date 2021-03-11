//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Eric Garlock on 3/11/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

class ImageCommentsSnapshotTests: XCTestCase {

	func test_emptyImageComments() {
		let sut = makeSUT()
		
		sut.display(ImageCommentsViewModel(comments: []))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGECOMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGECOMMENTS_dark")
	}
	
	func test_imageCommentsWithErrorMessage() {
		let sut = makeSUT()
		
		sut.display(ImageCommentErrorViewModel(message: "Couldn't connect to server"))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGECOMMENTS_WITH_ERROR_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGECOMMENTS_WITH_ERROR_dark")
	}
	
	func test_imageCommentsWithLongErrorMessage() {
		let sut = makeSUT()
		
		sut.display(ImageCommentErrorViewModel(message: "This is a\nlong error message\nwith multiple lines"))
		
		record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGECOMMENTS_WITH_LONG_ERROR_light")
		record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGECOMMENTS_WITH_LONG_ERROR_dark")
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
	
}

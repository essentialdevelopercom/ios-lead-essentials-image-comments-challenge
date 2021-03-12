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
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGECOMMENTS_EMPTY_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGECOMMENTS_EMPTY_dark")
	}
	
	func test_imageCommentsWithErrorMessage() {
		let sut = makeSUT()
		
		sut.display(ImageCommentErrorViewModel(message: "Couldn't connect to server"))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGECOMMENTS_WITH_ERROR_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGECOMMENTS_WITH_ERROR_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraLarge)), named: "IMAGECOMMENTS_WITH_ERROR_light_extraLarge")
	}
	
	func test_imageCommentsWithLongErrorMessage() {
		let sut = makeSUT()
		
		sut.display(ImageCommentErrorViewModel(message: "This is a\nlong error message\nwith multiple lines"))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGECOMMENTS_WITH_LONG_ERROR_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGECOMMENTS_WITH_LONG_ERROR_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraLarge)), named: "IMAGECOMMENTS_WITH_LONG_ERROR_light_extraLarge")
	}
	
	func test_imageCommentsWithContent() {
		let sut = makeSUT()
		
		let viewModel = ImageCommentsViewModel(comments: [
			ImageCommentViewModel(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus bibendum eu quam et hendrerit. Aliquam erat volutpat. Duis eleifend eros sagittis, tincidunt ex rutrum, malesuada ante. In turpis orci, accumsan et consequat et, commodo eu mauris. Morbi sagittis sodales velit, at faucibus erat euismod sed. Cras commodo, nisi sed scelerisque.", created: "30 seconds ago", username: "username0"),
			ImageCommentViewModel(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque ut.", created: "30 minutes ago", username: "username1"),
			ImageCommentViewModel(message: "💯", created: "1 day ago", username: "username2"),
			ImageCommentViewModel(message: "This is great!", created: "2 days ago", username: "username3")
		])
		
		sut.display(viewModel)
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGECOMMENTS_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGECOMMENTS_WITH_CONTENT_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraLarge)), named: "IMAGECOMMENTS_WITH_CONTENT_light_extraLarge")
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

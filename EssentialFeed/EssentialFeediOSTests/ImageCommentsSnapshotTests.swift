//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Lukas Bahrle Santana on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
	func test_emptyFeed() {
		let sut = makeSUT()
		
		sut.display(ImageCommentsViewModel(imageComments: []))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGECOMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGECOMMENTS_dark")
	}
	
	func test_imageCommentsWithErrorMessage() {
		let sut = makeSUT()
		
		sut.display(.error(message: "This is a\nmulti-line\nerror message"))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGECOMMENTS_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGECOMMENTS_WITH_ERROR_MESSAGE_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraLarge)), named: "IMAGECOMMENTS_WITH_ERROR_MESSAGE_extralarge_light")
	}
	
	func test_imageCommentsWithContent() {
		let sut = makeSUT()
		
		let comments: [PresentableImageComment] = [
			PresentableImageComment(message: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took", createdAt: "2 weeks ago", username: "Jen"),
			PresentableImageComment(message: "This is a comment", createdAt: "1 week ago", username: "Megan"),
			PresentableImageComment(message: "Other comment 😊", createdAt: "1 day ago", username: "Jim")
		]
		
		sut.display(ImageCommentsViewModel(imageComments: comments))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGECOMMENTS_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGECOMMENTS_WITH_CONTENT_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraLarge)), named: "IMAGECOMMENTS_WITH_CONTENT_extralarge_light")
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

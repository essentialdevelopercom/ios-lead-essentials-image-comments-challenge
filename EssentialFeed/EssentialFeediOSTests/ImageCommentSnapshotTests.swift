//
//  ImageCommentSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by alok subedi on 28/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

class ImageCommentSnapshotTests: XCTestCase {
	
	func test_emptyImageComment() {
		let sut = makeSUT()
		
		sut.display(emptyComments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENT_LIGHT")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENT_DARK")
	}
	
	func test_imageCommentWithErrorMessage() {
		let sut = makeSUT()
		
		sut.display(ImageCommentsErrorViewModel(message: "This is a\nmulti-line\nerror message"))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENT_WITH_ERROR_LIGHT")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENT_WITH_ERROR_DARK")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraSmall)), named: "IMAGE_COMMENT_WITH_ERROR_LIGHT_EXTRA_SMALL")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraSmall)), named: "IMAGE_COMMENT_WITH_ERROR_DARK_EXTRA_SMALL")
	}
	
	func test_imageCommentWithContent() {
		let sut = makeSUT()
		
		sut.display(imageCommentWithContent())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENT_WITH_CONTENT_LIGHT")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENT_WITH_CONTENT_DARK")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraSmall)), named: "IMAGE_COMMENT_WITH_CONTENT_LIGHT_EXTRA_SMALL")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraSmall)), named: "IMAGE_COMMENT_WITH_CONTENT_DARK_EXTRA_SMALL")
	}
	
	//MARK: Helpers
	
	private func makeSUT() -> ImageCommentsViewController {
		let bundle = Bundle(for: ImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "ImageComment", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyComments() -> ImageCommentsViewModel {
		return ImageCommentsViewModel(comments: [])
	}
	
	private func imageCommentWithContent() -> ImageCommentsViewModel {
		return ImageCommentsViewModel(comments: [
			PresentableImageComment(username: "Jen", message: "A Message", date: "5 hours ago"),
			PresentableImageComment(username: "Jack", message: "In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. Lorem ipsum may be used as a placeholder before final copy is available.", date: "33 minutes ago"),
			PresentableImageComment(username: "Megan", message: "A Message\n.\n.\n.\n.\n.\n.\n😀", date: "2 hours ago")
		])
	}
}

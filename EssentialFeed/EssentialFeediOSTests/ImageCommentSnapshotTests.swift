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
		
		record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENT_LIGHT")
		record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENT_DARK")
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
}

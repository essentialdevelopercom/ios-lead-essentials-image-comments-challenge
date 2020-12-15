//
//  FeedImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Maxim Soldatov on 11/29/20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedImageCommentsSnapshotTests: XCTestCase {

	func test_emptyComments() {
		let sut = makeSUT()
		
		sut.display(FeedImageCommentsViewModel(comments: []))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_EMPTY_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_EMPTY_COMMENTS_dark")
	}
	
	func test_imageWithComments() {
		let sut = makeSUT()

		sut.display(imageComments())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_COMMENTS_dark")
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_EXTRA_LARGE_COMMENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_EXTRA_LARGE_COMMENT_dark")
	}
	
	func test_feedImageCommentsWithError() {
		let sut = makeSUT()

		sut.display(.error(message: "An error message\n multiline\n error message"))

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_ERROR_MESSAGE_dark")
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_ERROR_MESSAGE_EXTRA_SIZED_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_ERROR_MESSAGE_EXTRA_SIZED_dark")
	}
	
	// MARK: -Helpers
	
	private func makeSUT() -> FeedImageCommentsViewController {
		let bundle = Bundle(for: FeedImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "FeedImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! FeedImageCommentsViewController

		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func imageComments() -> FeedImageCommentsViewModel {
		
		let first = FeedImageCommentPresentingModel(username: "Superman", comment: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin", creationTime: "2 weeks ago")
		
		let second = FeedImageCommentPresentingModel(username: "Spiderman", comment: "The East Side Gallery is an open-air gallery in Berlin.", creationTime: "2 hours ago")
		
		let third = FeedImageCommentPresentingModel(username: "Spiderman", comment: "The East Side Gallery is an open-air gallery in Berlin.", creationTime: "5 minutes ago")
		
		return FeedImageCommentsViewModel(comments: [first, second, third])
	}

}

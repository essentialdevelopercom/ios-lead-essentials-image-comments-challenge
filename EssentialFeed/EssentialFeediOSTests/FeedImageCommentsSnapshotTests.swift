//
//  FeedImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Ivan Ornes on 15/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class FeedImageCommentsSnapshotTests: XCTestCase {
	
	func test_emptyFeedImageComments() {
		let sut = makeSUT()
		
		sut.display(emptyFeedImageComments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENTS_FEED_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENTS_FEED_dark")
	}
	
	func test_feedImageWithComments() {
		let sut = makeSUT()
		
		sut.display(comments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_IMAGE_WITH_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_IMAGE_WITH_COMMENTS_dark")
	}
	
	func test_feedImageWithErrorMessage() {
		let sut = makeSUT()
		
		sut.display(.error(message: "This is a\nmulti-line\nerror message"))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_IMAGE_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_IMAGE_WITH_ERROR_MESSAGE_dark")
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> FeedImageCommentsViewController {
		let bundle = Bundle(for: FeedImageCommentsViewController.self)
		let storyboard = UIStoryboard(name: "FeedImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! FeedImageCommentsViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyFeedImageComments() -> [FeedImageCommentCellController] {
		return []
	}
	
	private func comments() -> [ImageCommentStub] {
		return [
			ImageCommentStub(message: "I'm baby kickstarter banjo microdosing +1 gentrify trust fund, cray craft beer selvage skateboard distillery lo-fi cred. Quinoa jean shorts fingerstache, kitsch beard normcore before they sold out mixtape master cleanse flannel.",
							 creationDate: "2 weeks ago",
							 author: "Jen"),
			ImageCommentStub(message: "Austin pour-over street art, sriracha gastropub snackwave ramps bicycle rights. Tumblr tumeric synth tattooed fanny pack, wayfarers bitters pinterest microdosing swag helvetica seitan try-hard. Vaporware cloud bread listicle, pinterest sustainable poutine farm-to-table deep v ethical salvia freegan church-key sriracha la croix.",
							 creationDate: "1 week ago",
							 author: "Megan"),
			ImageCommentStub(message: "💯",
							 creationDate: "3 days ago",
							 author: "Jim"),
			ImageCommentStub(message: "Selfies neutra trust fund humblebrag before 🐵 \n.\n.\n.\n🐯 they sold out tumblr mumblecore hella occupy gochujang.",
							 creationDate: "3 days ago",
							 author: "Jim")
		]
	}
}

extension FeedImageCommentsViewController {
	fileprivate func display(_ stubs: [ImageCommentStub]) {
		let cells: [FeedImageCommentCellController] = stubs.map { stub in
			FeedImageCommentCellController(viewModel: stub.viewModel)
		}
		
		display(cells)
	}
}

private class ImageCommentStub {
	let viewModel: FeedImageCommentViewModel
	
	init(message: String, creationDate: String, author: String) {
		viewModel = .init(message: message,
						  creationDate: creationDate,
						  author: author)
	}
}

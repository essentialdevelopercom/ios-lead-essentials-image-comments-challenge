//
//  ImageCommentSnapshotTest.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Mayorga on 4/13/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentSnapshotTests: XCTestCase {
	
	func test_emptyFeedImageComments() {
		let sut = makeSUT()
		
		sut.display(emptyFeedImageComments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENTS_FEED_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENTS_FEED_dark")
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> ImageCommentViewController {
		let bundle = Bundle(for: ImageCommentViewController.self)
		let storyboard = UIStoryboard(name: "ImageComment", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ImageCommentViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyFeedImageComments() -> [ImageCommentStub] {
		return []
	}
	
	private func comments() -> [ImageCommentStub] {
		return [
			ImageCommentStub(message: "I'm baby kickstarter banjo microdosing +1 gentrify trust fund, cray craft beer selvage skateboard distillery lo-fi cred. Quinoa jean shorts fingerstache, kitsch beard normcore before they sold out mixtape master cleanse flannel.",
							 creationDate: "2019-01-10T18:12:10+0000",
							 author: "Jen"),
			ImageCommentStub(message: "Austin pour-over street art, sriracha gastropub snackwave ramps bicycle rights. Tumblr tumeric synth tattooed fanny pack, wayfarers bitters pinterest microdosing swag helvetica seitan try-hard. Vaporware cloud bread listicle, pinterest sustainable poutine farm-to-table deep v ethical salvia freegan church-key sriracha la croix.",
							 creationDate: "2020-05-20T11:24:59+0000",
							 author: "Megan"),
			ImageCommentStub(message: "💯",
							 creationDate: "2021-04-12T12:21:57+0000",
							 author: "Jim"),
			ImageCommentStub(message: "Selfies neutra trust fund humblebrag before 🐵 \n.\n.\n.\n🐯 they sold out tumblr mumblecore hella occupy gochujang.",
							 creationDate: "2021-04-13T11:24:59+0000",
							 author: "Jim")
		]
	}
}

extension ImageCommentViewController {
	fileprivate func display(_ stubs: [ImageCommentStub]) {
		var commentModel: [ImageComment] = []
		stubs.forEach { commentModel.append($0.viewModel) }
		tableModel = commentModel
		tableView.reloadData()
		refreshControl?.endRefreshing()
	}
}

private class ImageCommentStub {
	let viewModel: ImageComment
	
	init(message: String, creationDate: String, author: String) {
		viewModel = .init(id: UUID(),
						  message: message,
						  createdAt: ISO8601DateFormatter().date(from: creationDate)!,
						  author: ImageCommentAuthor.init(username: author))
	}
}

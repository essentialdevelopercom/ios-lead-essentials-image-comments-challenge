//
//  Created by Azamat Valitov on 20.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS

class FeedCommentsSnapshotTests: XCTestCase {
	
	func test_emptyFeedComments() {
		let sut = makeSUT()
		
		sut.display(emptyFeedComments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_FEED_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_FEED_COMMENTS_dark")
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> FeedCommentsViewController {
		let bundle = Bundle(for: FeedCommentsViewController.self)
		let storyboard = UIStoryboard(name: "FeedComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! FeedCommentsViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyFeedComments() -> FeedCommentsViewModel {
		return FeedCommentsViewModel(comments: [])
	}
}

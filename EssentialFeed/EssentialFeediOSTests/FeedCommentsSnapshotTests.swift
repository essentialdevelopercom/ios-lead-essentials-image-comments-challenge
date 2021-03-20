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
	
	func test_feedCommentsWithContent() {
		let sut = makeSUT()
		
		sut.display(feedCommentsWithContent())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_COMMENTS_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_COMMENTS_WITH_CONTENT_dark")
	}
	
	func test_feedCommentsWithErrorMessage() {
		let sut = makeSUT()
		
		sut.display(.error(message: "This is a\nmulti-line\nerror message"))
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_COMMENTS_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_COMMENTS_WITH_ERROR_MESSAGE_dark")
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
	
	private func feedCommentsWithContent() -> FeedCommentsViewModel {
		return FeedCommentsViewModel(comments: [
			FeedCommentViewModel(name: "Jen", message: "Facilis ea harum deleniti official veritatis. Et sapiente saepe officia consectetur molestiae. Libero earum assumenda qui architecto repellendus explicabo laborum. Porro deleniti repellendus explicabo laborum. Porro deleniti sapiente ut iste non voluptatem optio", formattedDate: "2 weeks ago"),
			FeedCommentViewModel(name: "Megan", message: "Facilis ea harum deleniti officia veritatis.", formattedDate: "1 week ago"),
			FeedCommentViewModel(name: "Jim", message: "💯", formattedDate: "3 days ago"),
			FeedCommentViewModel(name: "Brian", message: """
Facilis ea harum deleniti officia veritatis. ☀️
.
.
.
.
.
.
✅
Libero earum assumenda qui architecto repellendus explicapo.
""", formattedDate: "1 hour ago")
		])
	}
}

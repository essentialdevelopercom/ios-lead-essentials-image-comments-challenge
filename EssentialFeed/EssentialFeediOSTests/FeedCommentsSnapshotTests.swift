import XCTest
import EssentialFeediOS
@testable import EssentialFeed

final class FeedCommentsSnapshotTests: XCTestCase {

    func test_emptyComments() {
		let sut = makeSUT()
		
		sut.display(emptyComments())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_COMMENTS_dark")
    }
	
	// MARK: - Helpers
	
	private func makeSUT() -> FeedImageCommentViewController {
		let bundle = Bundle(for: FeedImageCommentViewController.self)
		let storyboard = UIStoryboard(name: "FeedComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! FeedImageCommentViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyComments() -> [FeedImageCommentCellController] {
		return []
	}
}

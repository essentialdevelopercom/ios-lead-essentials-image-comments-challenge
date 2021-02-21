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
	
	func test_feedCommentsWithContent() {
		let sut = makeSUT()
		
		sut.display(feedCommentsWithContent())
		
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_COMMENTS_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_COMMENTS_WITH_CONTENT_dark")
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
	
	private func feedCommentsWithContent() -> [CommentStub] {
		return [
			CommentStub(message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.", 
						authorName: "Mario", 
						createdAt: "2 weeks ago"),
			
			CommentStub(message: "Hello world.", 
						authorName: "Alberto", 
						createdAt: "3 days ago")
		]
	}
	
	private func emptyComments() -> [FeedImageCommentCellController] {
		return []
	}
}

private extension FeedImageCommentViewController {
	func display(_ stubs: [CommentStub]) {
		let cells: [FeedImageCommentCellController] = stubs.map { stub in
			let cellController = FeedImageCommentCellController(model: stub.viewModel)
			return cellController
		}
		
		display(cells)
	}
}

private class CommentStub {
	let viewModel: CommentItemViewModel
	
	init(message: String, authorName: String, createdAt: String) {
		viewModel = CommentItemViewModel(message: message, 
										 authorName: authorName, 
										 createdAt: createdAt)
	}
}

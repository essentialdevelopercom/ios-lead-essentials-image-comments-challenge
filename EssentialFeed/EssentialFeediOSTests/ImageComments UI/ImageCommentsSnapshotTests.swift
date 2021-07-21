//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
	func test_imageCommentsWithContent() {
		let sut = makeSUT()

		sut.display(imageCommentsWithContent())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_CONTENT_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_WITH_CONTENT_light_extraExtraExtraLarge")
	}

	// MARK: - Helpers

	private func makeSUT() -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ListViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}

	private func imageCommentsWithContent() -> [CellController] {
		return [
			CellController(
				id: UUID(),
				ImageCommentCellController(
					viewModel: ImageCommentViewModel(
						message: "First Message",
						date: "2 days ago",
						authorUserName: "First username"
					)
				)
			),
			CellController(
				id: UUID(),
				ImageCommentCellController(
					viewModel: ImageCommentViewModel(
						message: "Second Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Very Long Message",
						date: "10 days ago",
						authorUserName: "Second very very very long username"
					)
				)
			)
		]
	}
}

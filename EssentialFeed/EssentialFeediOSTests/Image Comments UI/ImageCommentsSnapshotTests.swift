//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS

class ImageCommentsSnapshotTests: XCTestCase {
	func test_imageCommentsWithContent() {
		let sut = makeSUT()

		sut.display([
			ImageCommentCellController(viewModel: .init(username: "a username", createdAt: "5 seconds ago", message: "a message")),
			ImageCommentCellController(viewModel: .init(username: "another username", createdAt: "10 minutes ago", message: "another message")),
			ImageCommentCellController(viewModel: .init(username: "a long long long long long long long long long long long long long long long long long long long long long long long long username", createdAt: "10 months ago", message: "a long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long long  message"))
		])

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
}

private extension ListViewController {
	func display(_ cellControllers: [ImageCommentCellController]) {
		let cells: [CellController] = cellControllers.map { cellController in
			return CellController(id: UUID(), cellController)
		}

		display(cells)
	}
}

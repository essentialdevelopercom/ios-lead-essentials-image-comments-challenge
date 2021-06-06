
import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
	func test_imageCommentsWithContent() {
		let sut = makeSUT()

		sut.display(imageCommentsWithContent())

		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENT_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENT_WITH_CONTENT_dark")
		assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENT_WITH_CONTENT_light_extraExtraExtraLarge")
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

	private func imageCommentsWithContent() -> [ImageCommentStub] {
		return [
			ImageCommentStub(
				message: "short message",
				date: "1 day ago",
				username: "A."
			),
			ImageCommentStub(
				message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
				date: "1000 years ago",
				username: "long long long username"
			),
			ImageCommentStub(
				message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
				date: "13 min ago",
				username: "Username"
			)
		]
	}
}

private extension ListViewController {
	func display(_ stubs: [ImageCommentStub]) {
		let cells: [CellController] = stubs.map { stub in
			let cellController = ImageCommentCellController(viewModel: stub.viewModel)
			stub.controller = cellController
			return CellController(id: UUID(), cellController)
		}

		display(cells)
	}
}

private class ImageCommentStub {
	let viewModel: ImageCommentViewModel
	weak var controller: ImageCommentCellController?

	init(message: String, date: String, username: String) {
		self.viewModel = ImageCommentViewModel(message: message, date: date, username: username)
	}
}

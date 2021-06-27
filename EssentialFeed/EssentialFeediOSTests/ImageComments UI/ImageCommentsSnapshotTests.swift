
import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
	func test_imageCommentsWithContent() {
		let sut = makeSUT()

		sut.display(comments())

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

	private func imageCommentsWithContent() -> [ImageCommentCellController] {
		return [
			ImageCommentCellController(
				viewModel: ImageCommentViewModel(
					message: "short message",
					date: "1 day ago",
					username: "A."
				)),
			ImageCommentCellController(
				viewModel: ImageCommentViewModel(
					message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
					date: "1000 years ago",
					username: "long long long username"
				)),
			ImageCommentCellController(
				viewModel: ImageCommentViewModel(
					message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
					date: "13 min ago",
					username: "Username"
				))
		]
	}

	private func comments() -> [CellController] {
		imageCommentsWithContent().map { CellController(id: UUID(), $0) }
	}
}

//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
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

	private func imageCommentsWithContent() -> [ImageStub] {
		return [
			ImageStub(
				description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
				location: "East Side Gallery\nMemorial in Berlin, Germany",
				image: UIImage.make(withColor: .red)
			),
			ImageStub(
				description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
				location: "Garth Pier",
				image: UIImage.make(withColor: .green)
			)
		]
	}

	private func imageCommentsWithFailedImageLoading() -> [ImageStub] {
		return [
			ImageStub(
				description: nil,
				location: "Cannon Street, London",
				image: nil
			),
			ImageStub(
				description: nil,
				location: "Brighton Seafront",
				image: nil
			)
		]
	}
}

private extension ListViewController {
	func display(_ stubs: [ImageStub]) {
		let cells: [CellController] = stubs.map { stub in
			let cellController = ImageCommentsCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
			stub.controller = cellController
			return CellController(id: UUID(), cellController)
		}

		display(cells)
	}
}

private class ImageStub: ImageCommentsCellControllerDelegate {
	let viewModel: FeedImageViewModel
	let image: UIImage?
	weak var controller: ImageCommentsCellController?

	init(description: String?, location: String?, image: UIImage?) {
		self.viewModel = FeedImageViewModel(
			description: description,
			location: location)
		self.image = image
	}

	func didRequestImage() {
		controller?.display(ResourceLoadingViewModel(isLoading: false))

		if let image = image {
			controller?.display(image)
			controller?.display(ResourceErrorViewModel(message: .none))
		} else {
			controller?.display(ResourceErrorViewModel(message: "any"))
		}
	}

	func didCancelImageRequest() {}
}

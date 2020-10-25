//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

@testable import EssentialFeed
import EssentialFeediOS
import XCTest

final class ImageCommentsSnapshotTests: XCTestCase {
    func test_emptyComments() {
        let sut = makeSUT()

        sut.display(noComments())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_EMPTY_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_EMPTY_COMMENTS_dark")
    }

    // MARK: - Helpers

    private func makeSUT() -> ImageCommentsViewController {
        let bundle = Bundle(for: ImageCommentsViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ImageCommentsViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }

    private func noComments() -> ImageCommentsViewModel {
        ImageCommentsViewModel(comments: [])
    }
}

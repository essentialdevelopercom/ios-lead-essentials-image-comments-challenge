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

    func test_imageWithComments() {
        let sut = makeSUT()

        sut.display(imageComments())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_COMMENTS_dark")
    }

    func test_imageCommentsWithError() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_ERROR_dark")
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

    private func imageComments() -> ImageCommentsViewModel {
        let comment1 = PresentableImageComment(
            username: "Alfredo Hernandez",
            createdAt: "1 week ago",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        )
        let comment2 = PresentableImageComment(
            username: "Caio Zullo",
            createdAt: "2 weeks ago",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
        )
        let comment3 = PresentableImageComment(
            username: "Mike Apostolakis",
            createdAt: "1 hour ago",
            message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit\n.\n.\n.\n.\n✅"
        )
        let comment4 = PresentableImageComment(
            username: "Hernandez Alfredo",
            createdAt: "1 week ago",
            message: "☀️ Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. ☀️"
        )
        return ImageCommentsViewModel(comments: [comment1, comment2, comment3, comment4])
    }
}

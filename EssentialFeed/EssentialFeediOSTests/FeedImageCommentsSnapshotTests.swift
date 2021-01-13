//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedImageCommentsSnapshotTests: XCTestCase {
    
    func test_emptyComments() {
        let sut = makeSUT()
        
        sut.display(noComments())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENTS_dark")
    }
    
    // MARK: - Helpers

    private func makeSUT() -> FeedImageCommentsViewController {
        let bundle = Bundle(for: FeedImageCommentsViewController.self)
        let storyboard = UIStoryboard(name: "FeedImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedImageCommentsViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func noComments() -> FeedImageCommentsViewModel {
        return FeedImageCommentsViewModel(comments: [])
    }
}

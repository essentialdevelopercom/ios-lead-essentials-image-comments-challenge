//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class FeedImageCommentsSnapshotTests: XCTestCase {
    
    func test_emptyComments() {
        let sut = makeSUT()
        
        sut.display(noComments())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_IMAGE_COMMENTS_dark")
    }
    
    func test_noEmptyComments() {
        let sut = makeSUT()
        
        sut.display(imageWithContent())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_CONTENT_dark")
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraLarge)), named: "IMAGE_COMMENTS_WITH_EXTRA_LARGE_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraLarge)), named:  "IMAGE_COMMENTS_WITH_EXTRA_LARGE_CONTENT_dark")
    }
    
    func test_feedImageCommentsWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_WITH_ERROR_MESSAGE_dark")
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraLarge)), named: "IMAGE_COMMENTS_WITH_EXTRA_LARGE_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraLarge)), named:  "IMAGE_COMMENTS_WITH_EXTRA_LARGE_ERROR_MESSAGE_dark")
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
    
    private func imageWithContent() -> FeedImageCommentsViewModel {
        let coment0 = FeedImageCommentPresenterModel(
            username: "Some user name",
            creationTime: "2 weeks ago",
            comment: "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged")
        
        let coment1 = FeedImageCommentPresenterModel(
            username: "A very long long long username",
            creationTime: "1 week ago",
            comment: "Lorem Ipsum is simply dummy text of the printing and typesetting industry")
        
        let coment2 = FeedImageCommentPresenterModel(
            username: "Another user name",
            creationTime: "3 days ago",
            comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit\n.\n.\n.\n.\n✅")
        
        let coment3 = FeedImageCommentPresenterModel(
            username: "Last user name",
            creationTime: "1 hour ago",
            comment: "🤘🏻")
        
        return FeedImageCommentsViewModel(comments: [coment0, coment1, coment2, coment3])
    }
}

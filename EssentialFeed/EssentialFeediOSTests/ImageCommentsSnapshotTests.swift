//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Araceli Ruiz Ruiz on 08/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
    func test_emptyComments() {
        let sut = makeSUT()
        
        sut.display(emptyComments())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_COMMENTS_dark")
    }
    
    func test_commentsWithContent() {
        let sut = makeSUT()
        
        sut.display(commentsWithContent())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "COMMENTS_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "COMMENTS_WITH_CONTENT_dark")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
                
        sut.display(.error(message: "This is a\nmulti-line\n error message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "COMMENTS_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "COMMENTS_WITH_ERROR_MESSAGE_dark")
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
    
    private func emptyComments() -> [ImageCommentCellController] {
        return []
    }
    
    private func commentsWithContent() -> [ImageComment] {
        return [
            ImageComment(
                id: UUID(),
                message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tortor magna, porta at sem vitae, bibendum tincidunt nisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; ",
                createdAt: Date.distantPast,
                username: "username0"
            ),
            ImageComment(
                id: UUID(),
                message: "Nulla blandit condimentum tempor.",
                createdAt: Date.distantPast,
                username: "username1"
            )
        ]
    }
}

private extension ImageCommentsViewController {
    func display(_ comments: [ImageComment]) {
        let cells: [ImageCommentCellController] = comments.map { comment in
            let cellController = ImageCommentCellController(model: comment)
            return cellController
        }
        
        display(cells)
    }
}

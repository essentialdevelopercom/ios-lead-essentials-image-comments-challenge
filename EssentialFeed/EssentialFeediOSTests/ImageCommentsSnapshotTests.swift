//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Araceli Ruiz Ruiz on 08/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS

class ImageCommentsSnapshotTests: XCTestCase {
    func test_emptyComments() {
        let sut = makeSUT()
        
        sut.display(emptyComments())

        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_COMMENTS_light")
        record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_COMMENTS_dark")
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
}

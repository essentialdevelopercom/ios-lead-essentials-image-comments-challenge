//
//  ImageCommentsUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

extension ImageCommentsUIIntegrationTests {
    func assertThat(_ sut: ImageCommentsViewController, isRendering comments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedImageComments() == comments.count else {
            return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedImageComments()) instead.", file: file, line: line)
        }
        
		let viewModel = ImageCommentsPresenter.map(comments)
		
		viewModel.comments.enumerated().forEach { index, comment in
            assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor comment: ImageCommentViewModel, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.comment(at: index)

        guard let cell = view as? ImageCommentCell else {
            return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
		
        XCTAssertEqual(cell.author.text, comment.username, "Username at index (\(index))", file: file, line: line)

        XCTAssertEqual(cell.date.text, comment.date, "Relative date at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.message.text, comment.message, "Message at index (\(index))", file: file, line: line)
    }
}

//
//  ImageCommentsUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension ImageCommentsUIIntegrationTests {
    func assertThat(_ sut: ImageCommentsViewController, isRendering comments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
       guard sut.numberOfRenderedImageComments() == comments.count else {
            return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedImageComments()) instead.", file: file, line: line)
        }

        comments.enumerated().forEach { index, comment in
            assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor comment: ImageComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.comment(at: index)

        guard let cell = view as? ImageCommentCell else {
            return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        XCTAssertEqual(cell.author.text, comment.username, "Expected username text to be \(String(describing: comment.username)) for comment at index (\(index))", file: file, line: line)

        XCTAssertEqual(cell.date.text, comment.createdAt.relativeDate(), "Expected relative date text to be \(String(describing: comment.createdAt.relativeDate())) for comment at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.message.text, comment.message, "Expected message text to be \(String(describing: comment.message)) for comment at index (\(index))", file: file, line: line)
    }
}

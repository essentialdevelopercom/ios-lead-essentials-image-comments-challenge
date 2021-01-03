//
//  ImageCommentsUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Araceli Ruiz Ruiz on 05/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS
import EssentialFeed

extension ImageCommentsUIIntegrationTests {
    func assertThat(_ sut: ImageCommentsViewController, isRendering comments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedImageComments() == comments.count else {
            return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedImageComments()) instead.", file: file, line: line)
        }
        
		let viewModel = ImageCommentsViewModel(comments: comments.map {
			ImageCommentViewModel(
				message: $0.message,
				date: $0.createdAt.relativeDate(),
				username: $0.username)
		})
		
		viewModel.comments.enumerated().forEach { index, comment in
            assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor comment: ImageCommentViewModel, at index: Int, file: StaticString = #file, line: UInt = #line) {

		XCTAssertEqual(sut.commentUsername(at: index), comment.username, "Username at index (\(index))", file: file, line: line)

		XCTAssertEqual(sut.commentDate(at: index), comment.date, "Relative date at index (\(index))", file: file, line: line)
        
		XCTAssertEqual(sut.commentMessage(at: index), comment.message, "Message at index (\(index))", file: file, line: line)
    }
}

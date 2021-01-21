//
//  CommentUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Khoi Nguyen on 7/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
import EssentialFeediOS
import EssentialFeed
import XCTest

extension CommentUIIntegrationTests {
	func assertThat(_ sut: CommentViewController, isRendering comments: [PresentableComment], file: StaticString = #file, line: UInt = #line) {
		
		guard sut.numberOfRenderedComments() == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedComments()) instead", file: file, line: line)
		}
		
		comments.enumerated().forEach { index, comment in
			assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
		}
	}
	
	func assertThat(_ sut: CommentViewController, hasViewConfiguredFor comment: PresentableComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
		let view = sut.commentView(at: index)
		guard let cell = view as? CommentCell else {
			return XCTFail("Expected to get \(CommentCell.self), got \(String(describing: view)) instead")
		}

		XCTAssertEqual(cell.authorText, comment.author, "authorText at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.messageText, comment.message, "messageText at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.timestampText, comment.createAt, "timestampText at index \(index)", file: file, line: line)
	}
}
 

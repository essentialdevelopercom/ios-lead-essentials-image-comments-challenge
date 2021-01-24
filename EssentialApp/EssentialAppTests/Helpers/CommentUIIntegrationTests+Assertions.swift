//
//  CommentUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Robert Dates on 1/23/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS

extension CommentsUIIntegrationTests {
	func assertThat(_ sut: CommentsViewController, isRendering comments: [ExpectedCellContent], file: StaticString = #filePath, line: UInt = #line) {
		guard sut.numberOfRenderedCommentViews() == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedCommentViews()) instead.", file: file, line: line)
		}

		comments.enumerated().forEach { index, image in
			assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
		}
	}

	func assertThat(_ sut: CommentsViewController, hasViewConfiguredFor expected: ExpectedCellContent, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.commentView(at: index)

		guard let cell = view as? CommentCell else {
			return XCTFail("Expected \(CommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.usernameText, expected.username, "username in cell at index \(index)", file: file, line: line)

		XCTAssertEqual(cell.messageText, expected.message, "message in cell at index \(index)", file: file, line: line)

		XCTAssertEqual(cell.dateText, expected.date, "date in cell at index \(index)", file: file, line: line)
	}
}

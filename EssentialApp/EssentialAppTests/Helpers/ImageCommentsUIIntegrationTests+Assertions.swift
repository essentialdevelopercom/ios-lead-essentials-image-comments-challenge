//
//  ImageCommentsUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Cronay on 24.12.20.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeediOS

extension ImageCommentsUIIntegrationTests {
	func assertThat(_ sut: ImageCommentsViewController, isRendering comments: [ExpectedCellContent], file: StaticString = #filePath, line: UInt = #line) {
		guard sut.numberOfRenderedCommentViews() == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedCommentViews()) instead.", file: file, line: line)
		}

		comments.enumerated().forEach { index, image in
			assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
		}
	}

	func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor expected: ExpectedCellContent, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.commentView(at: index)

		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.usernameText, expected.username, "Expected cell at index \(index) to display \(expected.username), but displays \(String(describing: cell.usernameText)) instead", file: file, line: line)

		XCTAssertEqual(cell.messageText, expected.message, "Expected cell at index \(index) to display \(expected.message), but displays \(String(describing: cell.messageText)) instead", file: file, line: line)

		XCTAssertEqual(cell.dateText, expected.date, "Expected cell at index \(index) to display \(expected.date), but displays \(String(describing: cell.dateText)) instead", file: file, line: line)
	}
}

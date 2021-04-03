//
//  ImageCommentsIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Ángel Vázquez on 28/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import XCTest

extension ImageCommentsIntegrationTests {
	func assertThat(_ sut: ImageCommentsViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
		guard sut.numberOfRenderedComments() == comments.count else {
			return XCTFail("Expected \(comments.count) images, got \(sut.numberOfRenderedComments()) instead.", file: file, line: line)
		}
		
		comments.enumerated().forEach { index, comment in
			assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
		}
	}
	
	func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor comment: ImageComment, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: self)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.authorText, comment.author, "Author at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.messageText, comment.message, "Message at index \(index)", file: file, line: line)
		XCTAssertNotEqual(cell.creationDateText, "", "Date at index \(index)", file: file, line: line)
	}
}

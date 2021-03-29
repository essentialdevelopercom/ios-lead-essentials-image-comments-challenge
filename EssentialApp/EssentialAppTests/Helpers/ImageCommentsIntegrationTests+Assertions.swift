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
	func assertThat(_ sut: ImageCommentsViewController, isRendering pairs: [(comment: ImageComment, relativeDate: String)], file: StaticString = #filePath, line: UInt = #line) {
		guard sut.numberOfRenderedComments() == pairs.count else {
			return XCTFail("Expected \(pairs.count) images, got \(sut.numberOfRenderedComments()) instead.", file: file, line: line)
		}
		
		pairs.enumerated().forEach { index, pair in
			assertThat(sut, hasViewConfiguredFor: pair, at: index, file: file, line: line)
		}
	}
	
	func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor pair: (comment: ImageComment, relativeDate: String), at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: self)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.authorText, pair.comment.author, "Expected author to be \(pair.comment.author) for comment view at index \(index)", file: file, line: line)
		
		XCTAssertEqual(cell.messageText, pair.comment.message, "Expected message to be \(pair.comment.message) for comment view at index \(index)", file: file, line: line)
		
		XCTAssertEqual(cell.creationDateText, pair.relativeDate, "Expected relative date to be \(pair.relativeDate) for comment view at index \(index)", file: file, line: line)
	}
}

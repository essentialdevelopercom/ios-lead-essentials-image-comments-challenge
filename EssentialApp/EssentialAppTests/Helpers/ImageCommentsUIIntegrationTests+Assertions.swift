//
//  ImageCommentsUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Bogdan Poplauschi on 02/04/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension ImageCommentsUIIntegrationTests {
	func assertThat(
		_ sut: ImageCommentsViewController,
		isRendering imageComments: [PresentableImageComment],
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		guard sut.numberOfRenderedImageComments() == imageComments.count else {
			return XCTFail("Expected \(imageComments.count) images, got \(sut.numberOfRenderedImageComments()) instead.", file: file, line: line)
		}
		
		for (index, imageComment) in imageComments.enumerated() {
			assertThat(sut, hasViewConfiguredFor: imageComment, at: index)
		}
	}
	
	func assertThat(
		_ sut: ImageCommentsViewController,
		hasViewConfiguredFor imageComment: PresentableImageComment,
		at index: Int,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		guard let cell = sut.imageCommentView(at: index) else {
			return XCTFail("Expected \(ImageCommentCell.self) instance", file: file, line: line)
		}
		
		XCTAssertEqual(cell.usernameText, imageComment.author, "Expected username text to be \(String(describing: imageComment.author)) for image comment view at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.createdAtText, imageComment.createdAt, "Expected created at text to be \(String(describing: imageComment.createdAt)) for image comment view at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.commentText, imageComment.message, "Expected comment text to be \(String(describing: imageComment.author)) for image comment view at index \(index)", file: file, line: line)
	}
}

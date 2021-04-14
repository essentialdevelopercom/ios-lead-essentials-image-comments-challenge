//
//  ImageCommentsUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Sebastian Vidrea on 09.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension ImageCommentsUIIntegrationTests {
	func assertThat(_ sut: ImageCommentsViewController, isRendering imageComments: [ImageComment], file: StaticString = #file, line: UInt = #line) {
		guard sut.numberOfRenderedImageCommentViews() == imageComments.count else {
			return XCTFail("Expected \(imageComments.count) image comments, got \(sut.numberOfRenderedImageCommentViews()) instead.", file: file, line: line)
		}

		imageComments.enumerated().forEach { index, imageComment in
			assertThat(sut, hasViewConfiguredFor: imageComment, at: index, file: file, line: line)
		}
	}

	func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor imageComment: ImageComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)

		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.messageText, imageComment.message, "Expected message to be \(imageComment.message) for image comment view at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.userNameText, imageComment.username, "Expected username to be \(imageComment.username) for image comment view at index \(index)", file: file, line: line)
	}
}

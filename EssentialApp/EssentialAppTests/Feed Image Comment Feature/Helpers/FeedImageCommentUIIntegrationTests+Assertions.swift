//
//  FeedImageCommentUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Mario Alberto Barragán Espinosa on 11/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedImageCommentUIIntegrationTests {
	func assertThat(_ sut: FeedImageCommentViewController, isRendering feedComments: [FeedImageComment], file: StaticString = #file, line: UInt = #line) {
		guard sut.numberOfRenderedFeedImageCommentsViews() == feedComments.count else {
			return XCTFail("Expected \(feedComments.count) images, got \(sut.numberOfRenderedFeedImageCommentsViews()) instead.", file: file, line: line)
		}

		feedComments.enumerated().forEach { index, imageComment in
			assertThat(sut, hasViewConfiguredFor: imageComment, at: index, file: file, line: line)
		}
	}
	
	func assertThat(_ sut: FeedImageCommentViewController, hasViewConfiguredFor imageComment: FeedImageComment, at index: Int, file: StaticString = #file, line: UInt = #line) {
		let view = sut.feedImageCommentView(at: index)

		guard let cell = view as? FeedImageCommentCell else {
			return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.messageText, imageComment.message, "Expected message text to be \(String(describing: imageComment.message)) for image comment view at index (\(index))", file: file, line: line)

		XCTAssertEqual(cell.authorNameText, imageComment.author, "Expected author text to be \(String(describing: imageComment.author)) for image comment view at index (\(index))", file: file, line: line)
		
		let createdAtText = FeedCommentDatePolicy.getRelativeDate(for: imageComment.creationDate)
		
		XCTAssertEqual(cell.createdAtText, createdAtText, "Expected creation date text to be \(String(describing: createdAtText)) for image comment view at index (\(index))", file: file, line: line)
	}
}

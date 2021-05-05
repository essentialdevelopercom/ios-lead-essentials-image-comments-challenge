//
//  FeedImageCommentsUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Danil Vassyakin on 4/27/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
@testable import EssentialFeediOS

extension FeedImageCommentsUIIntegrationTests {
	
	func assertThat(_ sut: FeedCommentsViewController, isRendering comments: [FeedComment], file: StaticString = #filePath, line: UInt = #line) {
		guard sut.numberOfRenderedFeedCommentViews() == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedFeedCommentViews()) instead.", file: file, line: line)
		}
		let presentationComments = FeedImageCommentPresenter.presentableComments(
			from: comments,
			date: Date.init,
			locale: .current
		)
		
		presentationComments.enumerated().forEach { index, image in
			assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
		}
	}
	
	func assertThat(_ sut: FeedCommentsViewController, hasViewConfiguredFor expected: PresentationImageComment, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.commentView(at: index)

		guard let cell = view as? FeedCommentCell else {
			return XCTFail("Expected \(FeedCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.authorNameLabel.text, expected.author, "username in cell at index \(index)", file: file, line: line)

		XCTAssertEqual(cell.commentTextLabel.text, expected.message, "message in cell at index \(index)", file: file, line: line)

		XCTAssertEqual(cell.commentTimeLabel.text, expected.createdAt, "date in cell at index \(index)", file: file, line: line)
	}
	
}

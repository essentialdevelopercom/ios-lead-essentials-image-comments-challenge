//
//  ImageCommentsUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Adrian Szymanowski on 16/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import XCTest
import EssentialFeed
import EssentialFeediOS

extension ImageCommentsUIIntegrationTests {
	func assertThat(_ sut: ImageCommentsViewController, isRendering comments: [ImageComment], withRelativeDate relativeDate: () -> Date, file: StaticString = #file, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		let numberOfRenderedComments = sut.numberOfRenderedImageCommentsViews()
		guard numberOfRenderedComments == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(numberOfRenderedComments) instead", file: file, line: line)
		}
		
		comments
			.enumerated()
			.forEach { index, comment in
				assertThat(sut, hasViewConfiguredFor: comment, withRelativeDate: relativeDate, at: index, file: file, line: line)
			}
		
		executeRunLoopToCleanUpReferences()
	}
	
	func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor comment: ImageComment, withRelativeDate relativeDate: () -> Date, at index: Int, file: StaticString = #file, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.authorLabel.text, comment.author.username, "Expected author username to be \(String(describing: comment.author.username)) for comment view at index (\(index))", file: file, line: line)
		
		let formatter = RelativeDateTimeFormatter()
		let localizedDate = formatter.localizedString(for: comment.createdAt, relativeTo: relativeDate())
		
		XCTAssertEqual(cell.relativeDateLabel.text, localizedDate, "Expected relative date to be \(String(describing: localizedDate)) for comment view at index (\(index))", file: file, line: line)
		
		XCTAssertEqual(cell.messageLabel.text, comment.message, "Expected message to be \(String(describing: comment.message)) for comment view at index (\(index))", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
}

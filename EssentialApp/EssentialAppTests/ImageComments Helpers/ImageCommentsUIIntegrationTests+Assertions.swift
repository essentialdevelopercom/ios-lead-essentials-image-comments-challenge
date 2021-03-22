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
	func assertThat(_ sut: ImageCommentsViewController, isRendering comments: [ImageComment], timeFormatConfiguration: TimeFormatConfiguration, file: StaticString = #file, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		let numberOfRenderedComments = sut.numberOfRenderedImageCommentsViews()
		guard numberOfRenderedComments == comments.count else {
			return XCTFail("Expected \(comments.count) comments, got \(numberOfRenderedComments) instead", file: file, line: line)
		}
		
		ImageCommentsViewModelMapper.map(comments, timeFormatConfiguration: timeFormatConfiguration)
			.enumerated()
			.forEach { index, comment in
				assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
			}
		
		executeRunLoopToCleanUpReferences()
	}
	
	func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor viewModel: ImageCommentViewModel, at index: Int, file: StaticString = #file, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.authorLabel.text, viewModel.authorUsername, "Author name at index (\(index))", file: file, line: line)
		
		XCTAssertEqual(cell.relativeDateLabel.text, viewModel.createdAt, "Relative createdAt at index (\(index))", file: file, line: line)
		
		XCTAssertEqual(cell.messageLabel.text, viewModel.message, "Message at index (\(index))", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
}

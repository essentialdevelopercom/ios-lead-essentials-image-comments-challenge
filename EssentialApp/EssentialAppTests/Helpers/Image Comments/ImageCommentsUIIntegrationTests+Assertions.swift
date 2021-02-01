//
//  ImageCommentsUIIntegrationTests+Assertions.swift
//  EssentialAppTests
//
//  Created by Lukas Bahrle Santana on 01/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

extension ImageCommentsUIIntegrationTests {
	
	func assertThat(_ sut: ImageCommentsViewController, isRendering imageComments: [PresentableImageComment], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		
		guard sut.numberOfRenderedImageCommentViews() == imageComments.count else {
			return XCTFail("Expected \(imageComments.count) image comments, got \(sut.numberOfRenderedImageCommentViews()) instead.", file: file, line: line)
		}
		
		imageComments.enumerated().forEach { index, image in
			assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
		}
		
		executeRunLoopToCleanUpReferences()
	}
	
	func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor imageComment: PresentableImageComment, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.messageText, imageComment.message, "Expected message to be \(imageComment.message) for image comment view at index (\(index))", file: file, line: line)
		
		XCTAssertEqual(cell.createdAtText, imageComment.createdAt, "Expected date to be \(imageComment.createdAt) for image comment view at index (\(index))", file: file, line: line)
		
		XCTAssertEqual(cell.usernameText, imageComment.username, "Expected username to be \(imageComment.createdAt) for image comment view at index (\(index))", file: file, line: line)
	}
	
	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
}

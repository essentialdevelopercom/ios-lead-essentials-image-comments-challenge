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
	func assertThat(_ sut: ImageCommentsViewController, isRendering viewModels: [ImageCommentViewModel], file: StaticString = #filePath, line: UInt = #line) {
		guard sut.numberOfRenderedComments() == viewModels.count else {
			return XCTFail("Expected \(viewModels.count) images, got \(sut.numberOfRenderedComments()) instead.", file: file, line: line)
		}
		
		viewModels.enumerated().forEach { index, viewModel in
			assertThat(sut, hasViewConfiguredFor: viewModel, at: index, file: file, line: line)
		}
	}
	
	func assertThat(_ sut: ImageCommentsViewController, hasViewConfiguredFor viewModel: ImageCommentViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)
		
		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: self)) instead", file: file, line: line)
		}
		
		XCTAssertEqual(cell.authorText, viewModel.author, "Author at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.messageText, viewModel.message, "Message at index \(index)", file: file, line: line)
		XCTAssertEqual(cell.creationDateText, viewModel.creationDate, "Date at index \(index)", file: file, line: line)
	}
}
